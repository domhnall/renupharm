document.addEventListener("turbolinks:load", function(event){
  if(typeof gtag === "function"){
    gtag('config', 'UA-125632968-1', {
      'page_title' : event.target.location.pathname,
      'page_path': event.target.title
    });
  }
});
