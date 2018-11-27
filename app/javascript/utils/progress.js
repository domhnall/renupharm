const Progress = {

  init: function(){
    const self          = this,
          duration      = 1000,
          progress_bars = document.querySelectorAll(".progress.dynamic");

    setTimeout(function(){
      progress_bars.forEach(function(el){
        let width = el.getAttribute("data-width");
        el.querySelector(".progress-bar").style.width = width;
      });
    }, 1000);
  }
};

export default Progress;
