# frozen_string_literal: true

module Plans
  class OverrideService < BaseService
    def initialize(plan:, params:)
      @plan = plan
      @params = params

      super
    end

    def call
      return result.forbidden_failure! unless License.premium?

      ActiveRecord::Base.transaction do
        new_plan = plan.dup.tap do |p|
          p.amount_cents = params[:amount_cents] if params.key?(:amount_cents)
          p.amount_currency = params[:amount_currency] if params.key?(:amount_currency)
          p.description = params[:description] if params.key?(:description)
          p.invoice_display_name = params[:invoice_display_name] if params.key?(:invoice_display_name)
          p.name = params[:name] if params.key?(:name)
          p.trial_period = params[:trial_period] if params.key?(:trial_period)
          p.parent_id = plan.id
        end
        new_plan.save!

        if params[:tax_codes]
          taxes_result = Plans::ApplyTaxesService.call(plan: new_plan, tax_codes: params[:tax_codes])
          taxes_result.raise_if_error!
        end

        plan.charges.find_each do |charge|
          charge_params = (
            params[:charges]&.find { |p| p[:id] == charge.id } || {}
          ).merge(plan_id: new_plan.id)
          Charges::OverrideService.call(charge:, params: charge_params)
        end

        if params[:usage_thresholds].present? &&
            License.premium? &&
            plan.organization.progressive_billing_enabled?

          UsageThresholds::OverrideService.call(usage_thresholds_params: params[:usage_thresholds], new_plan: new_plan)
        end

        if params[:minimum_commitment].present? && License.premium?
          commitment = Commitment.new(plan: new_plan, commitment_type: "minimum_commitment")
          minimum_commitment_params = params[:minimum_commitment].merge(plan_id: new_plan.id)

          commitment_override_result = Commitments::OverrideService.call(commitment:, params: minimum_commitment_params)
          commitment_override_result.raise_if_error!
        end

        result.plan = new_plan
        track_plan_created(new_plan)
        result
      end

      result
    rescue ActiveRecord::RecordInvalid => e
      result.record_validation_failure!(record: e.record)
    rescue BaseService::FailedResult => e
      e.result
    end

    private

    attr_reader :plan, :params

    def track_plan_created(plan)
      count_by_charge_model = plan.charges.group(:charge_model).count

      SegmentTrackJob.perform_later(
        membership_id: CurrentContext.membership,
        event: "plan_created",
        properties: {
          code: plan.code,
          name: plan.name,
          invoice_display_name: plan.invoice_display_name,
          description: plan.description,
          plan_interval: plan.interval,
          plan_amount_cents: plan.amount_cents,
          plan_period: plan.pay_in_advance ? "advance" : "arrears",
          trial: plan.trial_period,
          nb_charges: plan.charges.count,
          nb_standard_charges: count_by_charge_model["standard"] || 0,
          nb_percentage_charges: count_by_charge_model["percentage"] || 0,
          nb_graduated_charges: count_by_charge_model["graduated"] || 0,
          nb_package_charges: count_by_charge_model["package"] || 0,
          organization_id: plan.organization_id,
          parent_id: plan.parent_id
        }
      )
    end
  end
end
