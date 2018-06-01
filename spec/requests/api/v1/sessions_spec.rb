require 'rails_helper'

RSpec.describe 'Sesssion API', type: :request do

    before { host! 'api.motoapp.dev' }
    let!(:user) { create(:user) }
    let(:headers) do
    {
        'Accept' => 'application/vnd.motoapp.v1' ,
        'Content-Type' => Mime[:json].to_s
    }
    end 

    describe 'POST /sessions' do
        before do
            post '/sessions', params: {session: credential}.to_json, headers: headers
        end

        context 'Quando a credencial estiver correta' do
            let(:credential) { { email: user.email, password: '123456'} }

            it 'Retorno do status = 200' do
                expect(response).to have_http_status(200)
            end

            it 'Retorno com informações do token' do
                user.reload
                expect(json_body[:auth_token]).to eq(user.auth_token)
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

    describe 'DELETE /sessions/:id' do

        let(:auth_token) { user.auth_token }

        before do
            delete "/sessions/#{auth_token}", params: {}, headers: headers
        end

        it 'Retorno do status = 204' do
            expect(response).to have_http_status(204)
        end

        it 'Confirma auteração do token do usuario' do
            expect(User.find_by(auth_token: auth_token)).to be_nil
        end

    end
end
