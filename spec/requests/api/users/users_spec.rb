require 'spec_helper'
describe 'Usercontroller API' do
  describe 'POST /users/morsel_subscribe users#morsel_subscribe' do
  	let(:current_user) { FactoryGirl.create(:user) }
  	let(:endpoint) { '/users/morsel_subscribe' }
  	it "should successfully create the subsciption" do
  		expect{  			
      	post_endpoint  user: { :subscriptions_attributes =>[{morsel_id: '1501'}]}
      }.to change { Subscription.count}.by(1)
  	end

  	it "should have response OK" do		
      	post_endpoint  user: { :subscriptions_attributes =>[{morsel_id: '1501'}]}
 				expect_success
  	end

 	end
end

