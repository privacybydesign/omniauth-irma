$(document).on("ready page:load", function() {
  $("#irma-login-button").click(function(e) {
    handle("/users/auth/irma", e);
  });

  $("#irma-register-button").click(function(e) {
    handle("/users/auth/irma?register=true", e);
  });

  function handle(url, e) {
    $.post(url, function(data) {
      irma.handleSession(data.sessionPtr).then(function() {
        console.log("done!");
        window.location.replace("/users/auth/irma/callback?sessiontoken=" + data.token);
      });
    });
    e.preventDefault();
  }
});
