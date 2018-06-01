require 'rails_helper'

RSpec.describe 'User API', type: :request do
    let!(:user) { create(:user) }
    let(:user_id) { user.id }
    let(:headers) do
    {
        'Accept' => 'application/vnd.motoapp.v1' ,
        'Content-Type' => Mime[:json].to_s,
        'Authorization' => user.auth_token
    }
    end 

    before { host! 'api.motoapp.dev' }

    describe 'GET /users/:id' do
        before do
            get "/users/#{user_id}", params: {}, headers: headers
        end

        context 'Quando o usuario existir' do
            it 'Retorno do usuario' do
                expect(json_body[:id]).to eq(user_id)
            end

            it 'Retorno do status = 200' do
                expect(response).to have_http_status(200)
            end
        end

        context 'Quando o usuario não existir' do
            let(:user_id) {1000}
            it 'Retorno do status = 404' do
                expect(response).to have_http_status(404)
            end
        end
    end

    describe 'POST /users' do
        before do
            post '/users', params: { user: user_params}.to_json, headers: headers
        end

        context 'Paramentros de usários válidos na criação' do
            let(:user_params) {attributes_for(:user)}

            it 'Retorno do status = 201' do
                expect(response).to have_http_status(201)
            end

            it 'Retorno de dados de usário criado' do
                expect(json_body[:email]).to eq(user_params[:email])
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

    describe 'PUT /users/:id' do
        before do
            put "/users/#{user_id}", params: { user: user_params}.to_json, headers: headers
        end

        context 'Paramentros de usários válidos na atualização' do
            let(:user_params) { {email: 'novo_email@teste.com'} }

            it 'Retorno do status = 200' do
                expect(response).to have_http_status(200)
            end

            it 'Retorno de dados de usário atualizado' do
                expect(json_body[:email]).to eq(user_params[:email])
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

    describe 'DELETE /users/:id' do
        before do
            delete "/users/#{user_id}", params: {}, headers: headers
        end

        it 'Retorno do status = 204' do
            expect(response).to have_http_status(204)
        end

        it 'Confirma exclusão de usuário do banco de dados' do
            expect(User.find_by(id: user.id) ).to be_nil
        end
    end


end
