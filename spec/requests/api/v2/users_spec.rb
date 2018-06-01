require 'rails_helper'

RSpec.describe 'User API', type: :request do
    let!(:user) { create(:user) }
    let!(:auth_data) { user.create_new_auth_token }
    let(:headers) do
    {
        'Accept' => 'application/vnd.motoapp.v2',
        'Content-Type' => Mime[:json].to_s,
        'access-token' => auth_data['access-token'],
        'uid' => auth_data['uid'],
        'client' => auth_data['client']
    }
    end 

    before { host! 'api.motoapp.dev' }

    describe 'GET /auth/validate_token' do

        context 'Quando o usuario existir com parametros validos' do

            before do
                get '/auth/validate_token', params: {}, headers: headers
            end

            it 'Retorno do usuario' do
                expect(json_body[:data][:id].to_i).to eq(user.id)
            end

            it 'Retorno do status = 200' do
                expect(response).to have_http_status(200)
            end
        end

        context 'Quando o usuario não existir ou parametros invalidos' do

            before do
                headers['access-token'] = '100200300'
                get '/auth/validate_token', params: {}, headers: headers
            end
    
            it 'Retorno do status = 401' do
                expect(response).to have_http_status(401)
            end
        end
    end

    describe 'POST /auth' do
        before do
            post '/auth', params: user_params.to_json, headers: headers
        end

        context 'Paramentros de usários válidos na criação' do
            let(:user_params) {attributes_for(:user)}

            it 'Retorno do status = 200' do
                expect(response).to have_http_status(200)
            end

            it 'Retorno de dados de usário criado' do
                expect(json_body[:data][:email]).to eq(user_params[:email])
            end

        end

        context 'Parametros de usuários inválidos na criação' do
            let(:user_params) {attributes_for(:user, email: 'jose.silva')}

            it 'Retorno do status = 422' do
                expect(response).to have_http_status(422)
            end

            it 'Retorno de erro de criação de usúário' do
                expect(json_body).to have_key(:errors)
            end
        end
    end

    describe 'PUT /auth' do
        before do
            put '/auth', params: user_params.to_json, headers: headers
        end

        context 'Paramentros de usários válidos na atualização' do
            let(:user_params) { {email: 'novo_email@teste.com'} }

            it 'Retorno do status = 200' do
                expect(response).to have_http_status(200)
            end

            it 'Retorno de dados de usário atualizado' do
                expect(json_body[:data][:email]).to eq(user_params[:email])
            end
        end

        context 'Parametros de usuários inválidos na atualização' do
            let(:user_params) {attributes_for(:user, email: 'luiz.silva')}

            it 'Retorno do status = 422' do
                expect(response).to have_http_status(422)
            end

            it 'Retorno de erro de criação de usúário' do
                expect(json_body).to have_key(:errors)
            end
        end
    end

    describe 'DELETE /auth' do
        before do
            delete '/auth', params: {}, headers: headers
        end

        it 'Retorno do status = 200' do
            expect(response).to have_http_status(200)
        end

        it 'Confirma exclusão de usuário do banco de dados' do
            expect(User.find_by(id: user.id) ).to be_nil
        end
    end


end
