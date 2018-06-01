require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user) { build (:user) }

  it { is_expected.to have_many(:tasks).dependent(:destroy)}

 #  before { @user = FactoryBot.build(:user) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive } 
  it { is_expected.to validate_confirmation_of(:password) }
  it { is_expected.to allow_value("teste@teste.com.br").for(:email) }
  it { is_expected.to validate_uniqueness_of(:auth_token) }

  describe '#info' do
    it 'retorna e-mail e data de criacao do usuario e um token' do
      user.save!
      allow(Devise).to receive(:friendly_token).and_return('abc123xwzTOKEN')

      expect(user.info).to eq("#{user.email} - #{user.created_at} - Token: abc123xwzTOKEN")
    end
  end

  describe 'generate_authentication_token!' do
    it 'gerar um token unico para usuario' do
      allow(Devise).to receive(:friendly_token).and_return('abc123xwzTOKEN')
      user.generate_authentication_token!

      expect(user.auth_token).to eq('abc123xwzTOKEN')
    end

    it 'gerar token já utilizado para outro usuario' do

      allow(Devise).to receive(:friendly_token).and_return('abc654TOKENmva', 'abc654TOKENmva', 'abc654TOKENrfm')
      existing_user = create(:user)

      user.generate_authentication_token!
      expect(user.auth_token).not_to eq(existing_user.auth_token)

    end
  end
end
