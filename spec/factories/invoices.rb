# frozen_string_literal: true

FactoryBot.define do
  factory :invoice do
    customer
    # TODO: change building invoices from billing_entity by default
    organization

    issuing_date { Time.zone.now - 1.day }
    payment_due_date { issuing_date }
    payment_status { "pending" }
    currency { "EUR" }

    organization_sequential_id { rand(1_000_000) }

    after :build do |invoice, values|
      invoice.billing_entity ||= values.organization&.default_billing_entity
    end

    trait :draft do
      status { :draft }
    end

    trait :credit do
      invoice_type { :credit }
    end

    trait :dispute_lost do
      payment_dispute_lost_at { DateTime.current - 1.day }
    end

    trait :with_tax_error do
      after :create do |i|
        create(:error_detail, owner: i, error_code: "tax_error")
      end
    end

    trait :with_tax_voiding_error do
      after :create do |i|
        create(:error_detail, owner: i, error_code: "tax_voiding_error")
      end
    end

    trait :failed do
      status { :failed }
    end

    trait :pending do
      status { :pending }
    end

    trait :subscription do
      transient do
        subscriptions { [create(:subscription)] }
      end

      invoice_type { :subscription }
      after :create do |invoice, evaluator|
        evaluator.subscriptions.each do |subscription|
          create(:invoice_subscription, :boundaries, invoice:, subscription:)
        end
      end
    end

    trait :self_billed do
      self_billed { true }
    end

    trait :invisible do
      status { Invoice::INVISIBLE_STATUS.keys.sample }
    end
  end
end
