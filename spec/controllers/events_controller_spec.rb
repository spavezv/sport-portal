require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.
#
# Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem.

RSpec.describe EventsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Event. As you add validations to Event, be sure to
  # adjust the attributes here as well.

  let(:valid_event_attributes) {
    FactoryBot.build(:event, owner: @user, max_teams: 20).attributes
  }

  let(:invalid_event_attributes) {
    FactoryBot.build(:event, name: nil).attributes
  }

  let(:valid_league_attributes) {
    FactoryBot.build(:league, owner: @user, max_teams: 20).attributes
  }

  let(:invalid_league_attributes) {
    FactoryBot.build(:league, name: nil).attributes
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # EventsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before(:each) do
    @user = FactoryBot.create(:user)
    @other_user = FactoryBot.create(:user)
    @admin = FactoryBot.create(:admin)
    @event = FactoryBot.build(:event)
    @event.owner = @user
    sign_in @user
  end

  after(:each) do
    Match.delete_all
    Event.delete_all
    @user.destroy
    @other_user.destroy
    @admin.destroy
  end

  describe "GET #index" do
    it "returns a success response if not signed in" do
      event = Event.create! valid_event_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_success
    end

    it "should allow normal user to view page" do
      get :index, params: {}
      expect(response).to be_success
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      event = Event.create! valid_event_attributes
      get :show, params: { id: event.to_param }, session: valid_session
      expect(response).to be_success
    end

    it "should allow normal user to view page" do
      event = Event.create! valid_event_attributes
      get :show, params: { id: event.to_param }
      expect(response).to be_success
    end
  end

  describe "GET #new" do
    it "returns a unauthorized response when not signed in" do
      sign_out @user
      get :new, params: {}, session: valid_session
      expect(response).to be_unauthorized
    end

    it "should allow normal user to view page" do
      get :new, params: {}
      expect(response).to be_success
    end
  end

  describe "GET #edit" do
    it "returns a unauthorized response" do
      sign_out @user
      event = Event.create! valid_event_attributes
      get :edit, params: { id: event.to_param }, session: valid_session
      expect(response).to be_unauthorized
    end

    it "should allow normal user to edit his created event" do
      event = Event.create! valid_event_attributes
      get :edit, params: { id: event.to_param }
      expect(response).to be_success
    end

    it "should not allow normal user to edit others created event" do
      sign_out @user
      sign_in @other_user
      event = Event.create! valid_event_attributes
      get :edit, params: { id: event.to_param }
      expect(response).to_not be_success
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:league_params) { {event: valid_league_attributes} }
      let(:tournament_params) { {event: FactoryBot.build(:tournament, owner: @user).attributes} }
      it "creates a new Event" do
        expect {
          post :create, params: league_params
        }.to change(Event, :count).by(1)
      end

      it "redirects to the created event" do
        post :create, params: league_params, session: valid_session
        expect(response).to redirect_to(Event.last)
      end

      it "should allow normal user to create a league" do
        post :create, params: league_params
        expect(response).to redirect_to(Event.last)
      end

      it "should allow normal user to create a tournament" do
        post :create, params: tournament_params
        expect(response).to redirect_to(Event.last)
      end
    end
    context "with invalid params" do
      let(:league_params) { {event: invalid_league_attributes} }
      let(:tournament_params) { {event: FactoryBot.build(:tournament, owner: @user, name: nil).attributes} }
      it "returns success when creating a league" do
        post :create, params: league_params, session: valid_session
        expect(response).to be_success
      end

      it "returns success when creating a tournament" do
        post :create, params: tournament_params, session: valid_session
        expect(response).to be_success
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
          deadline: Date.new(2017, 11, 20),
          startdate: Date.new(2017, 11, 21),
          enddate: Date.new(2017, 11, 22)
        }
      }

      it "updates the requested event" do
        event = Event.create! valid_event_attributes
        put :update, params: { id: event.to_param, event: new_attributes }, session: valid_session
        event.reload
        expect(event.deadline).to eq(Date.new(2017, 11, 20))
        expect(event.startdate).to eq(Date.new(2017, 11, 21))
        expect(event.enddate).to eq(Date.new(2017, 11, 22))
      end

      it "redirects to the event" do
        event = Event.create! valid_event_attributes
        put :update, params: { id: event.to_param, event: valid_event_attributes }, session: valid_session
        expect(response).to redirect_to(event)
      end

      it "should allow normal user to update his created event" do
        event = Event.create! valid_event_attributes
        put :update, params: { id: event.to_param, event: valid_event_attributes }
        expect(response).to redirect_to(event)
      end

      it "should not allow normal user to update others created events" do
        sign_out @user
        sign_in @other_user
        event = Event.create! valid_event_attributes
        put :update, params: { id: event.to_param, event: valid_event_attributes }
        expect(response).to_not be_success
      end
    end
    context "with invalid params" do
      it "returns success" do
        event = Event.create! valid_event_attributes
        put :update, params: { id: event.to_param, event: invalid_event_attributes }
        expect(response).to be_success
      end
    end
  end

  describe "PUT #join" do
    it "adds the user as participant to the event" do
      event = Event.create! valid_event_attributes
      put :join, params: { id: event.to_param }, session: valid_session
      expect(event).to have_participant(@user)
    end
  end

  describe "PUT #leave" do
    it "remove the user as participant of the event" do
      event = Event.create! valid_event_attributes
      event.add_participant(@user)
      put :leave, params: { id: event.to_param }, session: valid_session
      expect(event).not_to have_participant(@user)
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested event" do
      event = Event.create! valid_event_attributes
      delete :destroy, params: { id: event.to_param }
      expect(response).to be_redirect
      event.destroy
    end

    it "redirects to the events list" do
      event = Event.create! valid_event_attributes
      delete :destroy, params: { id: event.to_param }, session: valid_session
      expect(response).to redirect_to(events_url)
    end

    it "should not allow normal user to destroy events created by others" do
      sign_out @user
      sign_in @other_user
      event = Event.create! valid_event_attributes
      delete :destroy, params: { id: event.to_param }
      expect(response).to be_forbidden
    end

    it "should allow normal user to destroy his created event" do
      event = Event.create! valid_event_attributes
      delete :destroy, params: { id: event.to_param }
      expect(response).to redirect_to(events_url)
    end
  end

  describe "GET #schedule" do
    it "should generate schedule if not existing" do
      event = League.create! valid_league_attributes
      get :schedule, params: { id: event.to_param }, session: valid_session
      expect(event.matches).not_to be_empty
    end

    it "returns a success response" do
      event = League.create! valid_league_attributes
      get :schedule, params: { id: event.to_param }, session: valid_session
      expect(response).to be_success
    end
  end

  describe "GET #overview" do
    it "returns a success response" do
      tournament = Tournament.create! valid_attributes
      get :overview, params: { id: tournament.to_param }, session: valid_session
      expect(response).to be_success
    end
  end

end
