require 'rails_helper'

RSpec.describe 'User API', type: :request do
    let!(:user) { create(:user) }
    let(:headers) do
    {
        'Accept' => 'application/vnd.motoapp.v1' ,
        'Content-Type' => Mime[:json].to_s,
        'Authorization' => user.auth_token
    }
    end 

    before { host! 'api.motoapp.dev' }

    describe 'GET /tasks' do
        before do
            create_list(:task, 5, user_id: user.id)
            get '/tasks', params: {}, headers: headers
        end

        it 'Retorno do status = 200' do
            expect(response).to have_http_status(200)
        end

        it 'Retorno de 5(cinco) tarefas criadas' do
            expect(json_body[:tasks].count).to eq(5)
        end
    end

    describe 'GET /tasks/:id' do
        let(:task) { create(:task, user_id: user.id)}

        before do
            get "/tasks/#{task.id}", params: {}, headers: headers
        end

        it 'Retorno do status = 200' do
            expect(response).to have_http_status(200)
        end

        it 'Retorno de uma tarefas' do
            expect(json_body[:title]).to eq(task.title)
        end
    end

    describe 'POST /tasks' do
        before do
            post '/tasks', params: { task: task_params}.to_json, headers: headers
        end

        context 'Paramentros de tarefas válidos na criação' do
            let(:task_params) {attributes_for(:task)}

            it 'Retorno do status = 201' do
                expect(response).to have_http_status(201)
            end

            it 'Retorno de dados de tarefa criada' do
                expect(Task.find_by(title: task_params[:title])).not_to be_nil
            end

            it 'Retorno de dados de criação de tarefas' do
                expect(json_body[:title]).to eq(task_params[:title])
            end

            it 'Retorno de dados de associação de tarefas/usuario' do
                expect(json_body[:user_id]).to eq(user.id)
            end
        end

        context 'Paramentros de tarefas inválidos na criação' do
            let(:task_params) {attributes_for(:task, title: ' ')}

            it 'Retorno do status = 422' do
                expect(response).to have_http_status(422)
            end

            it 'Retorno de dados de tarefa criada' do
                expect(Task.find_by(title: task_params[:title])).to be_nil
            end

            it 'Retorno de erro de criação de tarefas' do
                expect(json_body[:errors]).to have_key(:title)
            end
        end
    end

    describe 'PUT /tasks/:id' do
        let(:task) { create(:task, user_id: user.id)}

        before do
            put "/tasks/#{task.id}", params: { task: task_params }.to_json, headers: headers
        end

        context 'Paramentros de tarefas válidos na alteração' do
            let(:task_params) { {title: 'Nova Tarefa à Realizar'}}

            it 'Retorno do status = 200' do
                expect(response).to have_http_status(200)
            end

            it 'Retorno de dados de tarefa atualizada' do
                expect(Task.find_by(title: task_params[:title])).not_to be_nil
            end

            it 'Retorno de dados de atualização de tarefas' do
                expect(json_body[:title]).to eq(task_params[:title])
            end

        end

        context 'Paramentros de tarefas inválidos na alteração' do
            let(:task_params) { {title: ''}}

            it 'Retorno do status = 422' do
                expect(response).to have_http_status(422)
            end

            it 'Retorno de dados de tarefa atualizada' do
                expect(Task.find_by(title: task_params[:title])).to be_nil
            end

            it 'Retorno de erro de atualiação de tarefas' do
                expect(json_body[:errors]).to have_key(:title)
            end
        end
    end


    describe 'DELETE /tasks/:id' do

        let!(:task) { create(:task, user_id: user.id)}

        before do
            delete "/tasks/#{task.id}", params: {}, headers: headers
        end

        it 'Retorno do status = 204' do
            expect(response).to have_http_status(204)
        end

        it 'Confirma exclusão de tarefa do banco de dados' do
            expect{Task.find(task.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
    end

end