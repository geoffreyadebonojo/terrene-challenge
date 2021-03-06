# spec/requests/todos_spec.rb
require 'rails_helper'

RSpec.describe 'Todos API', type: :request do
  # add todos owner
  let(:user) { create(:user) }
  let!(:todos) { create_list(:todo, 10, created_by: user.id) }
  let(:todo_id) { todos.first.id }
  # authorize request
  let(:headers) { valid_headers }

  # Test suite for GET /todos
  describe 'GET /v2/todos' do
    # make HTTP get request before each example
    before { get '/v2/todos', headers: valid_headers }

    it 'returns todos' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /todos/:id
  describe 'GET /v2/todos/:id' do
    before { get "/v2/todos/#{todo_id}", headers: valid_headers }

    context 'when the record exists' do
      it 'returns the todo' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(todo_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:todo_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Todo/)
      end
    end
  end

  # Test suite for POST /todos
  describe 'POST /v2/todos' do
    # valid payload
    let(:valid_attributes) { { title: 'Learn Elm', created_by: '1' }.to_json }

    context 'when the request is valid' do
      before { post '/v2/todos', params: valid_attributes, headers: valid_headers }

      it 'creates a todo' do
        expect(json['title']).to eq('Learn Elm')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/v2/todos', params: { title: 'Foobar' }.to_json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"message\":\"Missing token\"}")
      end
    end
  end

  # Test suite for PUT /todos/:id
  describe 'PUT /v2/todos/:id' do
    let(:valid_attributes) { { title: 'Shopping' }.to_json }

    context 'when the record exists' do
      before { put "/v2/todos/#{todo_id}", params: valid_attributes, headers: valid_headers }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  # Test suite for DELETE /todos/:id
  describe 'DELETE /v2/todos/:id' do
    before { delete "/v2/todos/#{todo_id}", headers: valid_headers }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end
