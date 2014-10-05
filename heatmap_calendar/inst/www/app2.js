$(document).ready(function(){
  
  function uploadcsv(file, header){
    //disable the button during upload
    $("#submitbutton").attr("disabled", "disabled");        
    
    //perform the request
    var req = ocpu.call("readcsvnew", {
      file : file,
      header : header
    }, function(session){
      //on success call heatmap_calendar()
      heatmap_calendar(session);
    });
    
    //if R returns an error, alert the error message
    req.fail(function(){
      alert("Server error: " + req.responseText);
    });
    
    //after request complete, re-enable the button 
    req.always(function(){
      $("#submitbutton").removeAttr("disabled")
    });        
  }    
  
  function heatmap_calendar(mydata){
    //perform the request
    var req2 = ocpu.call("heatmap_calendar", {
      mydata : mydata
    }, function(session){

    //read the session properties (just for fun)
    $("#printlink").attr("href", session.getLoc() + "/zip");
	$("#plotdiv").attr("href", session.getFile() + "heatmap.png");
})
  }

  $("#submitbutton").on("click", function(){
    
    //arguments
    var myheader = $("#header").val() == "true";
    var myfile = $("#csvfile")[0].files[0];
    
    if(!myfile){
      alert("No file selected.");
      return;
    }
    
    uploadcsv(myfile, myheader);        
  });
});