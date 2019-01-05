const Truncate = {
  init: function(selector_scope = ""){
    const self = this,
          max = 250;

    document.querySelectorAll(`${selector_scope} .truncate`).forEach(function(el){
      const orig_text = el.innerHTML;
      if(orig_text.length<=max){
        return;
      }

      const truncate = function(){
        el.innerHTML = `${orig_text.substr(0,max-1)} &hellip; ${self.see_more_html}`;
        el.querySelector(".see_more").addEventListener("click", function(event){
          event.stopPropagation();
          expand();
        }, true);
      };

      const expand = function(){
        el.innerHTML = `${orig_text} ${self.see_less_html}`;
        el.querySelector(".see_less").addEventListener("click", function(event){
          event.stopPropagation();
          truncate();
        }, true);
      };

      truncate();
    });

  },

  see_more_html: `<div class="see_more btn btn-secondary">See more</div>`,
  see_less_html: `<div class="see_less btn btn-secondary">See less</div>`,
};

export default Truncate;
