# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::Coupons::Destroy, type: :graphql do
  let(:required_permission) { "coupons:delete" }
  let(:membership) { create(:membership) }
  let(:organization) { membership.organization }
  let(:coupon) { create(:coupon, organization:) }

  let(:mutation) do
    <<-GQL
      mutation($input: DestroyCouponInput!) {
        destroyCoupon(input: $input) { id }
      }
    GQL
  end

  it_behaves_like "requires current user"
  it_behaves_like "requires permission", "coupons:delete"

  it "deletes a coupon" do
    result = execute_graphql(
      current_user: membership.user,
      permissions: required_permission,
      query: mutation,
      variables: {
        input: {id: coupon.id}
      }
    )

    data = result["data"]["destroyCoupon"]
    expect(data["id"]).to eq(coupon.id)
  end
end
