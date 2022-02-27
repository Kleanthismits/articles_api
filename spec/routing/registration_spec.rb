require 'rails_helper'

RSpec.describe 'registration routes' do
  it 'should route to registrations#create' do
    expect(post('/signup')).to route_to('registrations#create')
  end
end
