// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
//= require rails-ujs

import "@hotwired/turbo-rails"
import "controllers"

// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import Rails from "@hotwired/turbo-rails";
import "@hotwired/turbo-rails"; // Ensure this import is correct
import "controllers";

import 'bootstrap';
import 'bootstrap/dist/css/bootstrap.min.css';
import '../stylesheets/application.scss'; // Adjust the path if necessary
import Rails from "@rails/ujs";
Rails.start();

import Turbolinks from 'turbolinks';
Turbolinks.start();
