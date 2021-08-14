gem "devise"

after_bundle do
  run "yarn add bootstrap jquery @popperjs/core"

  append_to_file 'config/webpack/environment.js', after: "const { environment } = require('@rails/webpacker')\n" do
    <<-CODE.strip_heredoc
    const webpack = require("webpack");
    environment.plugins.append(
      "Provide",
      new webpack.ProvidePlugin({
        $: "jquery",
        jQuery: "jquery",
        Popper: ["popper.js", "default"]
      })
    );
    CODE
  end

  append_to_file 'app/javascript/packs/application.js', after: /import "channels"\n/ do
    <<-CODE.strip_heredoc
      import "bootstrap"
      import "../stylesheets/application"
      
      var jQuery = require('jquery')
      global.$ = global.jQuery = jQuery;
      window.$ = window.jQuery = jQuery;
      CODE
  end

  run "mkdir app/javascript/stylesheets"

  create_file "app/javascript/stylesheets/application.scss" do
    <<-CODE.strip_heredoc
    @import "~bootstrap/scss/bootstrap";
    CODE
  end

  run "bundle exec spring stop"
  generate "devise:install"
  generate :devise, "User"
  generate "migration AddNameToUsers name:string"
  rails_command("db:migrate")

  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'

  append_to_file 'db/seeds.rb'  do
    <<-CODE.strip_heredoc
    User.create!(
      name: "Smith",
      email: "smith@example.com",
      password: "111111"
    )
    User.create!(
      name: "James",
      email: "james@example.com",
      password: "111111"
    )
    User.create!(
      name: "John",
      email: "john@example.com",
      password: "111111"
    )
    User.create!(
      name: "Mary",
      email: "mary@example.com",
      password: "111111"
    )
    User.create!(
      name: "Helen",
      email: "helen@example.com",
      password: "111111"
    )
    User.create!(
      name: "Maria",
      email: "maria@example.com",
      password: "111111"
    )
    User.create!(
      name: "William",
      email: "william@example.com",
      password: "111111"
    )
    CODE
  end

  rails_command("db:seed")

  create_file "app/controllers/homes_controller.rb" do
    <<-CODE.strip_heredoc
    class HomesController < ApplicationController
      def top
      end
    end
    CODE
  end

  route "root 'homes#top'"

  create_file "app/views/homes/top.html.erb" do
    <<-CODE.strip_heredoc
    <main class="mt-5">
      <div class="starter-template text-center">
        <h1>Welcome to my template.</h1>
        <p class="lead">Use this template as a way to quickly start any new project.</p>
      </div>
    </main>
    CODE
  end

  create_file "app/views/devise/sessions/new.html.erb" do
    <<-CODE.strip_heredoc
    <div class="row mt-5">
      <div class="col-6 offset-3">
        <h2 class="text-center mb-4">Log in</h2>
        <%= form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>
          <div class="form-group mb-4">
            <%= f.label :email %>
            <%= f.email_field :email, autofocus: true, autocomplete: "email", class: "form-control form-control-lg" %>
          </div>
        
          <div class="form-group mb-5">
            <%= f.label :password %>
            <%= f.password_field :password, autocomplete: "current-password", class: "form-control form-control-lg" %>
          </div>
          
          <%= f.submit "Log in", class: "btn btn-lg btn-primary btn-block mb-3" %>
        <% end %>
        <p class="text-center">
          <%= link_to "Sign up", new_user_registration_path %>
        </p>
      </div>
    </div>
    CODE
  end

  create_file "app/views/devise/registrations/new.html.erb" do
    <<-CODE.strip_heredoc
    <div class="row mt-5">
      <div class="col-6 offset-3">
        <h2 class="text-center mb-4">Sign up</h2>
        <%= form_for(resource, as: resource_name, url: registration_path(resource_name)) do |f| %>
          <%= render "devise/shared/error_messages", resource: resource %>
          <div class="form-group mb-4">
            <%= f.label :name %>
            <%= f.text_field :name, class: "form-control form-control-lg" %>
          </div>

          <div class="form-group mb-4">
            <%= f.label :email %>
            <%= f.email_field :email, class: "form-control form-control-lg" %>
          </div>

          <div class="form-group mb-4">
            <%= f.label :password %>
            <% if @minimum_password_length %>
            <em>(<%= @minimum_password_length %> characters minimum)</em>
            <% end %><br />
            <%= f.password_field :password, autocomplete: "new-password", class: "form-control form-control-lg" %>
          </div>

          <div class="form-group mb-5">
            <%= f.label :password_confirmation %>
            <%= f.password_field :password_confirmation, autocomplete: "new-password", class: "form-control form-control-lg" %>
          </div>

          <%= f.submit "Sign up", class: "btn btn-lg btn-primary btn-block mb-3" %>
        <% end %>
        <p class="text-center">
          <%= link_to "Log in", new_user_session_path %>
        </p>
      </div>
    </div>
    CODE
  end

  create_file "app/views/devise/shared/_error_messages.html.erb" do
    <<-CODE.strip_heredoc
    <% if resource.errors.any? %>
      <div id="error_explanation">
        <h2 class="text-danger">
          <%= I18n.t("errors.messages.not_saved",
                    count: resource.errors.count,
                    resource: resource.class.model_name.human.downcase)
          %>
        </h2>
        <ul>
          <% resource.errors.full_messages.each do |message| %>
            <li><%= message %></li>
          <% end %>
        </ul>
      </div>
    <% end %>
    CODE
  end

  append_to_file 'app/views/layouts/application.html.erb', after: /<body>\n/  do
    <<-CODE
    <nav class="navbar navbar-expand-md navbar-dark bg-dark p-3">
      <%= link_to root_path, class: "navbar-brand" do %>
        LOGO
      <% end %>
    
      <div class="collapse navbar-collapse" id="navbarsExample03">
        <ul class="navbar-nav">
          <% if user_signed_in? %>
            <li class="nav-item active">
              <%= link_to "Log out", destroy_user_session_path, method: :delete, class: "nav-link" %>
            </li>
          <% else %>
            <li class="nav-item active">
              <%= link_to 'Log in', new_user_session_path, class: "nav-link" %>
            </li>
            <li class="nav-item active">
              <%= link_to 'Sign up', new_user_registration_path, class: "nav-link" %>
            </li>
          <% end %>
        </ul>
      </div>
    </nav>

    <% if flash[:notice] %>
      <div class="alert alert-primary text-center" role="alert"><strong><%= notice %></strong></div>
    <% end %>
    <% if flash[:alert] %>
      <div class="alert alert-danger text-center" role="alert"><strong><%= alert %></strong></div>
    <% end %>
    CODE
  end

  generate(:controller, "users")

  append_to_file 'config/routes.rb', after: "devise_for :users\n"  do
    <<-CODE
  resources :users
    CODE
  end

  append_to_file 'app/controllers/application_controller.rb', after: "ActionController::Base\n"  do
    <<-CODE
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource) 
    user_path(current_user)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
    CODE
  end

  append_to_file 'app/controllers/users_controller.rb', after: "ApplicationController\n" do
    <<-CODE
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
  end
    CODE
  end

  run "touch app/views/users/show.html.erb"

  append_to_file 'app/views/users/show.html.erb' do
    <<-CODE.strip_heredoc
    <section class="py-5 text-center container">
      <div class="row py-lg-5">
        <div class="col-lg-6 col-md-8 mx-auto">
          <svg width="80" height="80" class="svg-icon" viewBox="0 0 20 20">
            <path d="M12.075,10.812c1.358-0.853,2.242-2.507,2.242-4.037c0-2.181-1.795-4.618-4.198-4.618S5.921,4.594,5.921,6.775c0,1.53,0.884,3.185,2.242,4.037c-3.222,0.865-5.6,3.807-5.6,7.298c0,0.23,0.189,0.42,0.42,0.42h14.273c0.23,0,0.42-0.189,0.42-0.42C17.676,14.619,15.297,11.677,12.075,10.812 M6.761,6.775c0-2.162,1.773-3.778,3.358-3.778s3.359,1.616,3.359,3.778c0,2.162-1.774,3.778-3.359,3.778S6.761,8.937,6.761,6.775 M3.415,17.69c0.218-3.51,3.142-6.297,6.704-6.297c3.562,0,6.486,2.787,6.705,6.297H3.415z"></path>
          </svg>
          <h1 class="fw-light"><%= @user.name %></h1>
          <% if @user == current_user %>
            <p class="lead text-muted">You're currently signed in as <%= current_user.email %></p>
          <% end %>
        </div>
      </div>
    </section>
    CODE
  end


  run "sudo rm -r .git"
  git :init
  git branch: " -m main " 
  git add: "."
  git commit: " -m 'Initial commit' "

  say
  say "Template successfully created!", :green
  say
  say "Switch to your app by running:"
  say "$ cd #{app_name}", :green
  say
  say "Then run:"
  say "$ rails server", :green
end
