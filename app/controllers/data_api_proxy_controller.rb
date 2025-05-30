# frozen_string_literal: true

class DataApiProxyController < ApplicationController
  # Proxy for /mrrs/:organization_id/
  def mrrs
    billing_entity_id = current_organization.default_billing_entity.id
    query = <<~GRAPHQL
      query Mrrs($billingEntityId: ID) {
        dataApiMrrs(billingEntityId: $billingEntityId) {
          collection {
            amountCurrency
            startingMrr
            endingMrr
            mrrNew
            mrrExpansion
            mrrContraction
            mrrChurn
            mrrChange
            startOfPeriodDt
            endOfPeriodDt
          }
        }
      }
    GRAPHQL

    result = LagoApiSchema.execute(
      query,
      variables: { billingEntityId: billing_entity_id },
      context: graphql_context
    )
    Rails.logger.error(result.inspect)
    if result['errors']
      render json: { errors: result['errors'] }, status: :unprocessable_entity
    elsif result['data'] && result['data']['dataApiMrrs']
      render json: result['data']['dataApiMrrs']
    else
      render json: { error: "No data returned from GraphQL" }, status: :internal_server_error
    end
  end

  # Proxy for /mrrs/:organization_id/plans/
  def mrrs_plans
    query = <<~GRAPHQL
      query MrrsPlans($organizationId: ID!) {
        dataApiMrrsPlans(organizationId: $organizationId) {
          collection {
            amountCurrency
            dt
            planId
            activeCustomersCount
            mrr
            mrrShare
            planName
            planCode
            planDeletedAt
            planInterval
            activeCustomersShare
          }
          metadata {
            currentPage
            nextPage
            prevPage
            totalCount
            totalPages
          }
        }
      }
    GRAPHQL

    result = LagoApiSchema.execute(
      query,
      variables: { organizationId: params[:organization_id] },
      context: graphql_context
    )
    Rails.logger.error(result.inspect)
    if result['errors']
      render json: { errors: result['errors'] }, status: :unprocessable_entity
    elsif result['data'] && result['data']['dataApiMrrsPlans']
      render json: result['data']['dataApiMrrsPlans']
    else
      render json: { error: "No data returned from GraphQL" }, status: :internal_server_error
    end
  end

  # Proxy for /revenue_streams/:organization_id/
  def revenue_streams
    query = <<~GRAPHQL
      query RevenueStreams($organizationId: ID!) {
        dataApiRevenueStreams(organizationId: $organizationId) {
          amountCurrency
          couponsAmountCents
          grossRevenueAmountCents
          netRevenueAmountCents
          commitmentFeeAmountCents
          oneOffFeeAmountCents
          subscriptionFeeAmountCents
          usageBasedFeeAmountCents
          endOfPeriodDt
          startOfPeriodDt
        }
      }
    GRAPHQL

    result = LagoApiSchema.execute(
      query,
      variables: { organizationId: params[:organization_id] },
      context: graphql_context
    )
    Rails.logger.error(result.inspect)
    if result['errors']
      render json: { errors: result['errors'] }, status: :unprocessable_entity
    elsif result['data'] && result['data']['dataApiRevenueStreams']
      render json: result['data']['dataApiRevenueStreams']
    else
      render json: { error: "No data returned from GraphQL" }, status: :internal_server_error
    end
  end

  # Proxy for /revenue_streams/:organization_id/plans/
  def revenue_streams_plans
    query = <<~GRAPHQL
      query RevenueStreamsPlans($organizationId: ID!) {
        dataApiRevenueStreamsPlans(organizationId: $organizationId) {
          collection {
            planCode
            planDeletedAt
            planId
            planInterval
            planName
            customersCount
            customersShare
            amountCurrency
            grossRevenueAmountCents
            grossRevenueShare
            netRevenueAmountCents
            netRevenueShare
          }
          metadata {
            currentPage
            nextPage
            prevPage
            totalCount
            totalPages
          }
        }
      }
    GRAPHQL

    result = LagoApiSchema.execute(
      query,
      variables: { organizationId: params[:organization_id] },
      context: graphql_context
    )
    Rails.logger.error(result.inspect)
    if result['errors']
      render json: { errors: result['errors'] }, status: :unprocessable_entity
    elsif result['data'] && result['data']['dataApiRevenueStreamsPlans']
      render json: result['data']['dataApiRevenueStreamsPlans']
    else
      render json: { error: "No data returned from GraphQL" }, status: :internal_server_error
    end
  end

  # Proxy for /revenue_streams/:organization_id/customers/
  def revenue_streams_customers
    query = <<~GRAPHQL
      query RevenueStreamsCustomers($organizationId: ID!) {
        dataApiRevenueStreamsCustomers(organizationId: $organizationId) {
          collection {
            customerDeletedAt
            customerId
            customerName
            externalCustomerId
            amountCurrency
            grossRevenueAmountCents
            grossRevenueShare
            netRevenueAmountCents
            netRevenueShare
          }
          metadata {
            currentPage
            nextPage
            prevPage
            totalCount
            totalPages
          }
        }
      }
    GRAPHQL

    result = LagoApiSchema.execute(
      query,
      variables: { organizationId: params[:organization_id] },
      context: graphql_context
    )
    Rails.logger.error(result.inspect)
    if result['errors']
      render json: { errors: result['errors'] }, status: :unprocessable_entity
    elsif result['data'] && result['data']['dataApiRevenueStreamsCustomers']
      render json: result['data']['dataApiRevenueStreamsCustomers']
    else
      render json: { error: "No data returned from GraphQL" }, status: :internal_server_error
    end
  end

  # Proxy for /usages/:organization_id/invoiced/
  def usages_invoiced
    billing_entity_id = current_organization.default_billing_entity.id
    query = <<~GRAPHQL
      query UsagesInvoiced($billingEntityId: ID) {
        invoicedUsages(billingEntityId: $billingEntityId) {
          endOfPeriodDt
          startOfPeriodDt
          billableMetricCode
          amountCents
          amountCurrency
        }
      }
    GRAPHQL

    result = LagoApiSchema.execute(
      query,
      variables: { billingEntityId: billing_entity_id },
      context: graphql_context
    )
    Rails.logger.error(result.inspect)
    if result['errors']
      render json: { errors: result['errors'] }, status: :unprocessable_entity
    elsif result['data'] && result['data']['dataApiUsagesInvoiced']
      render json: result['data']['dataApiUsagesInvoiced']
    else
      render json: { error: "No data returned from GraphQL" }, status: :internal_server_error
    end
  end

  private

  # Prefer organization_id param, fall back to header-based concern
  def current_organization
    if params[:organization_id].present?
      @current_organization ||= Organization.find_by(id: params[:organization_id])
    else
      super if defined?(super)
    end
  end

  def graphql_context
    # Add any context needed for authentication, etc.
    {}
  end
end
