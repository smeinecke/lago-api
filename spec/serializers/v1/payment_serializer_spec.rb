# frozen_string_literal: true

require "rails_helper"

RSpec.describe ::V1::PaymentSerializer do
  subject(:serializer) do
    described_class.new(payment, root_name: "payment", includes:)
  end

  context "when payable is an invoice" do
    let(:payment) { create(:payment) }

    context "when includes is empty" do
      let(:includes) { [] }

      it "serializes the object" do
        result = JSON.parse(serializer.to_json)

        expect(result["payment"]).to include(
          "lago_id" => payment.id,
          "invoice_ids" => [payment.payable.id],
          "amount_cents" => payment.amount_cents,
          "amount_currency" => payment.amount_currency,
          "payment_status" => payment.payable_payment_status,
          "type" => payment.payment_type,
          "reference" => payment.reference,
          "external_payment_id" => payment.provider_payment_id,
          "created_at" => payment.created_at.iso8601
        )
      end
    end

    context "when includes payment_receipt is set" do
      let(:payment_receipt) { create(:payment_receipt) }
      let(:payment) { payment_receipt.payment }
      let(:includes) { %i[payment_receipt] }

      it "includes the payment receipt" do
        result = JSON.parse(serializer.to_json)

        expect(result["payment"]["payment_receipt"]).to include(
          "lago_id" => payment_receipt.id,
          "number" => payment_receipt.number,
          "created_at" => payment_receipt.created_at.iso8601
        )
      end
    end
  end

  context "when payable is a payment request" do
    let(:payment) { create(:payment, payable: payment_request) }
    let(:payment_request) { create(:payment_request, payment_status: "succeeded") }

    before do
      create(:payment_request_applied_invoice, payment_request:)
    end

    context "when includes is empty" do
      let(:includes) { [] }

      it "serializes the object" do
        result = JSON.parse(serializer.to_json)

        expect(result["payment"]).to include(
          "lago_id" => payment.id,
          "invoice_ids" => payment_request.invoice_ids,
          "amount_cents" => payment.amount_cents,
          "amount_currency" => payment.amount_currency,
          "payment_status" => payment.payable_payment_status,
          "type" => payment.payment_type,
          "reference" => payment.reference,
          "external_payment_id" => payment.provider_payment_id,
          "created_at" => payment.created_at.iso8601
        )
      end
    end

    context "when includes payment_receipt is set" do
      let(:includes) { %i[payment_receipt] }
      let!(:payment_receipt) { create(:payment_receipt, payment:) }

      it "includes the payment receipt" do
        result = JSON.parse(serializer.to_json)

        expect(result["payment"]["payment_receipt"]).to include(
          "lago_id" => payment_receipt.id,
          "number" => payment_receipt.number,
          "created_at" => payment_receipt.created_at.iso8601
        )
      end
    end
  end
end
