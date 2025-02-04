import jQuery from 'jquery'
window.jQuery = jQuery
window.$ = jQuery

$(document).ready(() => {
    $("#btnGetEmail").click((e) => {
        const resource = $("#resource").val();
        alert(resource) 
        e.preventDefault()
        var email = $("#getEmail").val()

        if (email.length > 0) $("#msgloading").html("Carregando...")
        fetch(`/api/v1/opt?email=${email}&resource=${resource}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
            }}).then(response => {
            return response.json().then(function (data) {
                $("#optdone").val(data.opt)
                $("#msgloading").addClass("hidden")
                $("#btnGetEmail").addClass("hidden")
                $("#divbtn").removeClass("hidden")
                
                if(!data.isUser){
                    $("#msg").html(data.msg)
                    $("#divpassword").addClass("hidden")
                    $("#divbtn").addClass("hidden")
                    $("#submitbtn").addClass("hidden")
                    return
                }else{
                    $("#divpassword").removeClass("hidden")
                }

              
                if(data.opt) {
                   $("#divbtn").removeClass("hidden")
                }else{
  
                  $("#divbtn").addClass("hidden")
                  $("#submitbtn").removeClass("hidden")
                }
            });
        })
    })

    $("#divbtn").click((e) => {
        e.preventDefault()
        $("#divemail").addClass("hidden")
        $("#divbtn").addClass("hidden")
        $("#reset_password").addClass("hidden")
        $("#divpassword").addClass("hidden")
        $("#divcode").removeClass("hidden")
        $("#reset_opt").removeClass("hidden")
        $("#submitbtn").removeClass("hidden")

        var optdone = $("#optdone").val()
        var email = $("#getEmail").val()
        fetch(`/api/v1/send_code?opt=${optdone}&email=${email}&resource=<%=resource.class.to_s %>`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
            }}).then(response => {
                if(response === true) $("#msgcode").html("Enviamos o codigo para seu E-mail!!!")
        })
    })

    $(".lock_password").click((e) => {
        var _type = $("#inputpasswordlock").attr("type")

        if(_type == 'password'){
            $("#inputpasswordlock").attr("type", "text")
            $("#lock_password_off").removeClass("hidden")
            $("#lock_password_on").addClass("hidden")
        }else{
            $("#inputpasswordlock").attr("type", "password")
            $("#lock_password_on").removeClass("hidden")
            $("#lock_password_off").addClass("hidden")
        }
    })

    $(".lock_otp_attempt").click((e) => {
        var _type = $("#inputotpattemptlock").attr("type")

        if(_type == 'password'){
            $("#inputotpattemptlock").attr("type", "text")
            $("#lock_otp_attempt_off").removeClass("hidden")
            $("#lock_otp_attempt_on").addClass("hidden")
        }else{
            $("#inputotpattemptlock").attr("type", "password")
            $("#lock_otp_attempt_on").removeClass("hidden")
            $("#lock_otp_attempt_off").addClass("hidden")
        }
    })  

})