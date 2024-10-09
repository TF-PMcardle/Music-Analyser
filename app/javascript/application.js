// Import Rails UJS for DELETE method handling in links (like logout)
import Rails from "@rails/ujs";
Rails.start();

// Turbo for faster navigation and partial page updates (no need for Turbolinks if using Turbo)
import { Turbo } from "@hotwired/turbo-rails";
Turbo.start();

// Import controllers (for Stimulus or other logic in your app)
import "controllers";

// Bootstrap and stylesheets
import 'bootstrap';
import 'bootstrap/dist/css/bootstrap.min.css';
import '../stylesheets/application.scss'; // Adjust the path if necessary
