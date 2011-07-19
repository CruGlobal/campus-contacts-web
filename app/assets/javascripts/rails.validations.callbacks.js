// clientSideValidations.callbacks.element.fail = function(element, message, callback) {
//   callback();
//   if (element.data('valid') !== false) {
//     element.parent().find('.message').hide().show('slide', {direction: "left", easing: "easeOutBounce"}, 500);
//   }
// };
// 
// clientSideValidations.callbacks.element.pass = function(element, callback) {
//   // Take note how we're passing the callback to the hide() 
//   // method so it is run after the animation is complete.
//   element.parent().find('.message').hide('slide', {direction: "left"}, 500, callback);
// };