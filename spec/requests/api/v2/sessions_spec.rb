require 'rails_helper'

RSpec.describe 'Sesssion API', type: :request do

    before { host! 'api.motoapp.dev' }
    let!(:auth_data) { user.create_new_auth_token }
    let!(:user) { create(:user) }
    let(:headers) do
        {
            'Accept' => 'application/vnd.motoapp.v2',
            'Content-Type' => Mime[:json].to_s,
            'access-token' => auth_data['access-token'],
            'uid' => auth_data['uid'],
            'client' => auth_data['client']
        }
        end

    describe 'POST /auth/sign_in' do
        before do
            post '/auth/sign_in', params: credential.to_json, headers: headers
        end

        context 'Quando a credencial estiver correta' do
            let(:credential) { { email: user.email, password: '123456'} }

            it 'Retorno do status = 200' do
                expect(response).to have_http_status(200)
            end

            it 'Retorno com informações de autenticação no Header' do
                expect(response.headers).to have_key('access-token')
                expect(response.headers).to have_key('uid')
                expect(response.headers).to have_key('client')

            end
        end

        context 'Quando a credencial estiver incorreta' do
            let(:credential) { { email: user.email, password: '1111111'} }

            it 'Retorno do status = 401' do
                expect(response).to have_http_status(401)
            end

            it 'Retorno com informações do token' do
                expect(json_body).to have_key(:errors)
            end
        end
    end

    describe 'DELETE /auth/sign_out' do

        let(:auth_token) { user.auth_token }

        before do
            delete '/auth/sign_out', params: {}, headers: headers
        end

        it 'Retorno do status = 200' do
            expect(response).to have_http_status(200)
        end

        it 'Confirma auteração do token do usuario' do
            user.reload
            expect(user.valid_token?(auth_data['access-token'], auth_data['client'])).to eq(false)
        end

    end
end
