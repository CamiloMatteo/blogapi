require "rails_helper"
require "byebug"

RSpec.describe "Posts", type: :request do
  describe "GET /posts" do
    before { get '/posts' }

    it "should return OK" do
      payload = JSON.parse(response.body)

      expect(payload).to be_empty
      expect(response).to have_http_status(200)
    end

    describe "with data in the bd" do
      let!(:posts) { create_list(:post, 10, published: true) }

      it "should return all the published posts" do
        get "/posts"
        payload = JSON.parse(response.body)

        expect(payload.size).to eq(posts.size)
        expect(response).to have_http_status(200)
      end
    end

  end

  describe "GET /posts/{id}" do
    let!(:post) { create(:post) }
    
    it "should return a post" do
      get "/posts/#{post.id}"

      payload = JSON.parse(response.body)

      expect(payload).not_to be_empty
      expect(payload["id"]).to eq(post.id)
      expect(response).to have_http_status(200)
    end
  end

  describe "PUT /posts/{id}" do
    let!(:article) { create(:post) }

    it "should update post" do
      req_payload = {
        update: {
          title: 'title2',
          content: 'content2',
          published: true
        }
      }
      # PUT http
      put "/posts/#{article.id}", params: req_payload
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload["id"]).to eq(article.id)
      expect(response).to have_http_status(:ok)
    end

    it "should return error on update in post" do
      req_payload = {
        update: {
          title: nil,
          content: nil,
          published: true
        }
      }
      # PUT http
      put "/posts/#{article.id}", params: req_payload
      payload = JSON.parse(response.body)

      expect(payload).not_to be_empty
      expect(payload["error"]).not_to be_empty
      expect(response).to have_http_status(:unprocessable_entity)

    end
  end

  describe "POST /posts" do
    let!(:user) { create(:user) }

    it "should create a post" do
      req_payload = {
        post: {
          title: 'title',
          content: 'content',
          published: false,
          user_id: user.id
        }
      }
      #POST http
      post "/posts", params: req_payload

      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload["id"]).not_to be_nil
      expect(response).to have_http_status(:created)
    end

    it "should return error message on invalid post" do
      req_payload = {
        post: {
          content: 'content',
          published: false,
          user_id: user.id
        }
      }
      #POST http
      post "/posts", params: req_payload

      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload["error"]).not_to be_empty
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end