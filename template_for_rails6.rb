gem 'devise'

after_bundle do
  run "yarn add bootstrap jquery popper.js"

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
  rails_command("db:migrate")

  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'

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
            <%= f.label :email %>
            <%= f.email_field :email, autofocus: true, autocomplete: "email", class: "form-control form-control-lg" %>
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
    <nav class="navbar navbar-expand-md navbar-dark bg-dark">
      <%= link_to root_path, class: "navbar-brand" do %>
        LOGO
      <% end %>
      <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarsExample03" aria-controls="navbarsExample03" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
    
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