# spec/requests/items_spec.rb
require 'rails_helper'

RSpec.describe 'Items API', type: :request do
  let(:user) { create(:user) }
  let!(:todo) { create(:todo, created_by: user.id) }
  let!(:items) { create_list(:item, 20, todo_id: todo.id) }
  let(:todo_id) { todo.id }
  let(:id) { items.first.id }
  let(:headers) { valid_headers }

  # Test suite for GET /todos/:todo_id/items
  describe 'GET /v1/todos/:todo_id/items' do

    context 'without pagination' do
      before { get "/v1/todos/#{todo_id}/items", headers: headers }

      context 'when todo exists' do
        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'returns all todo items' do
          expect(json.size).to eq(20)
        end
      end

      context 'when todo does not exist' do
        let(:todo_id) { 0 }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find Todo/)
        end
      end
    end

    context 'test pagination' do
      let!(:todo1) { create(:todo, created_by: user.id) }
      let!(:items1) { create_list(:item, 20, todo_id: todo1.id) }
      before { get "/v1/todos/#{todo_id}/items", params: {page: 1, results_per_page: 5}, headers: headers }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns correct number of items' do
        expect(json.size).to eq(5)
      end

      # These edge cases kinda weird me out, need more visibility into business logic
      it 'can handle nil page number by returning first page' do
        get "/v1/todos/#{todo_id}/items", params: {results_per_page: 5}, headers: headers
        expect(json.size).to eq(5)
      end

      it 'can handle nil results_per_page number by returning all items' do
        get "/v1/todos/#{todo_id}/items", params: {page: 1}, headers: headers
        expect(json.size).to eq(20)
      end

      it 'can handle nil results_per_page number with page > 1 by returning no items' do
        get "/v1/todos/#{todo_id}/items", params: {page: 2}, headers: headers
        expect(json.size).to eq(0)
      end

      it 'returns correct page of items' do
        first_page = json

        get "/v1/todos/#{todo_id}/items", params: {page: 2, results_per_page: 5}, headers: headers
        second_page = json

        expect(second_page).to_not eq(first_page)
      end
    end
  end

  # Test suite for GET /todos/:todo_id/items/:id
  describe 'GET /v1/todos/:todo_id/items/:id' do
    before { get "/v1/todos/#{todo_id}/items/#{id}", headers: headers }

    context 'when todo item exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the item' do
        expect(json['id']).to eq(id)
      end
    end

    context 'when todo item does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Item/)
      end
    end
  end

  # Test suite for PUT /todos/:todo_id/items
  describe 'POST /v1/todos/:todo_id/items' do
    let(:valid_attributes) { { name: 'Visit Narnia', done: false }.to_json }

    context 'when request attributes are valid' do
      before { post "/v1/todos/#{todo_id}/items", params: valid_attributes, headers: headers }

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when an invalid request' do
      before { post "/v1/todos/#{todo_id}/items", params: {}, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a failure message' do
        expect(response.body).to match(/Validation failed: Name can't be blank/)
      end
    end
  end

  # Test suite for PUT /todos/:todo_id/items/:id
  describe 'PUT /v1/todos/:todo_id/items/:id' do
    let(:valid_attributes) { { name: 'Mozart' }.to_json }

    before { put "/v1/todos/#{todo_id}/items/#{id}", params: valid_attributes, headers: headers }

    context 'when item exists' do
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end

      it 'updates the item' do
        updated_item = Item.find(id)
        expect(updated_item.name).to match(/Mozart/)
      end
    end

    context 'when the item does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Item/)
      end
    end
  end

  # Test suite for DELETE /todos/:id
  describe 'DELETE /v1/todos/:id' do
    before { delete "/v1/todos/#{todo_id}/items/#{id}", headers: headers }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end
