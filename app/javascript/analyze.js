document.addEventListener("DOMContentLoaded", function() {
  const fileInput = document.getElementById('fileInput');
  const analyzeButton = document.getElementById('analyzeButton');

  // Add an event listener to detect when a file is selected
  fileInput.addEventListener('change', function() {
    if (fileInput.files.length > 0) {
      analyzeButton.disabled = false;  // Enable button if file is selected
    } else {
      analyzeButton.disabled = true;   // Disable button if no file is selected
    }
  });
});
