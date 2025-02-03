import { Application } from "@hotwired/stimulus"
import $ from 'jquery';

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application
window.$ = $;
console.log("jquery")
console.log($)

export { application }
