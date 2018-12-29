const handle_delete = function(event){
  const parent = event.target.closest(".product_image"),
        id     = parent.getAttribute("data-id"),
        form   = event.target.closest("form"),
        input  = form.querySelector("#marketplace_product_delete_images");

  parent.querySelector(".image").classList.add("deleted");
  parent.querySelector(".actions .delete_image").classList.add("hidden");
  parent.querySelector(".actions .undo").classList.remove("hidden");
  input.value = [input.value, id].filter(i => i).join(",");
};

const handle_undo = function(event){
  const parent = event.target.closest(".product_image"),
        id     = parent.getAttribute("data-id"),
        form   = event.target.closest("form"),
        input  = form.querySelector("#marketplace_product_delete_images");

  parent.querySelector(".image").classList.remove("deleted");
  parent.querySelector(".actions .delete_image").classList.remove("hidden");
  parent.querySelector(".actions .undo").classList.add("hidden");
  input.value = input.value.split(",").filter(t => t!==id).join(",");
};

const RemoveUploads = {
  init: function(){
    document.querySelectorAll(".product_image .actions .delete_image").forEach(b => b.addEventListener("click", handle_delete));
    document.querySelectorAll(".product_image .actions .undo").forEach(b => b.addEventListener("click", handle_undo));
  },

};

export default RemoveUploads;
