# frozen_string_literal: true

class DataApiProxyController < ApplicationController
  # Proxy for /mrrs/:organization_id/
  def mrrs
    result = LagoSchema.execute(
      <<~GRAPHQL,
        variables: { organizationId: params[:organization_id] },
        context: graphql_context
      query Mrrs($organizationId: ID!) {
        dataApiMrrs(organizationId: $organizationId) {
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
    )
    render json: result['data']['dataApiMrrs']
  end

  # Proxy for /mrrs/:organization_id/plans/
  def mrrs_plans
    result = LagoSchema.execute(
      <<~GRAPHQL,
        variables: { organizationId: params[:organization_id] },
        context: graphql_context
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
    )
    render json: result['data']['dataApiMrrsPlans']
  end

  # Proxy for /revenue_streams/:organization_id/
  def revenue_streams
    result = LagoSchema.execute(
      <<~GRAPHQL,
        variables: { organizationId: params[:organization_id] },
        context: graphql_context
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
    )
    render json: result['data']['dataApiRevenueStreams']
  end

  # Proxy for /revenue_streams/:organization_id/plans/
  def revenue_streams_plans
    result = LagoSchema.execute(
      <<~GRAPHQL,
        variables: { organizationId: params[:organization_id] },
        context: graphql_context
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
    )
    render json: result['data']['dataApiRevenueStreamsPlans']
  end

  # Proxy for /revenue_streams/:organization_id/customers/
  def revenue_streams_customers
    result = LagoSchema.execute(
      <<~GRAPHQL,
        variables: { organizationId: params[:organization_id] },
        context: graphql_context
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
    )
    render json: result['data']['dataApiRevenueStreamsCustomers']
  end

  # Proxy for /usages/:organization_id/invoiced/
  def usages_invoiced
    result = LagoSchema.execute(
      <<~GRAPHQL,
        variables: { organizationId: params[:organization_id] },
        context: graphql_context
      query UsagesInvoiced($organizationId: ID!) {
        dataApiUsagesInvoiced(organizationId: $organizationId) {
          endOfPeriodDt
          startOfPeriodDt
          billableMetricCode
          amountCents
          amountCurrency
        }  
      }
      GRAPHQL
    )
    render json: result['data']['dataApiUsagesInvoiced']
  end

  private

  def graphql_context
    # Add any context needed for authentication, etc.
    {}
  end
end
