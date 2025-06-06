# frozen_string_literal: true

module Wallets
  module RecurringTransactionRules
    class UpdateService < BaseService
      def initialize(wallet:, params:)
        @wallet = wallet
        @params = params

        super
      end

      def call
        created_recurring_rules_ids = []

        hash_recurring_rules = params.map { |m| m.to_h.deep_symbolize_keys }
        hash_recurring_rules.each do |payload_rule|
          lago_id = payload_rule[:lago_id]
          rule = payload_rule.except(:lago_id)
          recurring_rule = wallet.recurring_transaction_rules.active.find_by(id: lago_id)

          if recurring_rule
            recurring_rule.update!(rule)

            next
          end

          # NOTE: on creation, we follow the wallet configuration if not set
          unless rule.key?(:invoice_requires_successful_payment)
            rule[:invoice_requires_successful_payment] = wallet.invoice_requires_successful_payment
          end
          created_recurring_rule = wallet.recurring_transaction_rules.create!(rule)
          created_recurring_rules_ids.push(created_recurring_rule.id)
        end

        # NOTE: Delete recurring_rules that are no more linked to the wallet
        sanitize_recurring_rules(hash_recurring_rules, created_recurring_rules_ids)

        result.wallet = wallet
        result
      end

      private

      attr_reader :wallet, :params

      def sanitize_recurring_rules(args_recurring_rules, created_recurring_rules_ids)
        updated_recurring_rules_ids = args_recurring_rules.reject { |m| m[:lago_id].nil? }.map { |m| m[:lago_id] }
        not_needed_ids =
          wallet.recurring_transaction_rules.pluck(:id) - updated_recurring_rules_ids - created_recurring_rules_ids

        wallet.recurring_transaction_rules.where(id: not_needed_ids).find_each do |recurring_transaction_rule|
          Wallets::RecurringTransactionRules::TerminateService.call(recurring_transaction_rule:)
        end
      end
    end
  end
end
