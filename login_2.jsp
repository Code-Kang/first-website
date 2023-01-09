<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>개발샘플</title>
    <!-- App favicon -->
    <link rel="shortcut icon" href="/static/images/favicon2.png" />
    <!-- base:css -->
    <link rel="stylesheet" href="/static/css/materialdesignicons.min.css">
    <link rel="stylesheet" href="/static/css/vendor.bundle.base.css">
    <link rel="stylesheet" href="/static/css/style.css">
    <!-- inject:css -->
    <link rel="stylesheet" href="/static/css/app.css">
    <script src="/static/js/vendor.bundle.base.js"></script>
    <script src="/static/js/hoverable-collapse.js"></script>
    <script src="/static/js/template.js"></script>
    <script src="/static/js/settings.js"></script>
    <script src="/static/js/todolist.js"></script>
</head>
<script>
    $(function() {
        $('#loading').hide();
    });

    function proc() {

        var formData = $("#form").serialize();

        if($("#usId").val() == ""){
            alert("아이디를 입력하세요");
            $('#usId').focus();
            return;
        }else if($("#usPassword").val() == ""){
            alert("비밀번호를 입력하세요");
            $('#usPassword').focus();
            return;
        }

        $.ajax({
            type : "POST",
            url : "/common/userLogin.do",
            data :formData,
            dataType : "json",
            async : false,
            success : function(data) {
                if(data.failCnt > 3) {
                    alert(data.failCntMsg);
                    return;
                }else if(data.flg == "N"){
                    alert(data.msg);
                }else if(data.flg == "Y"){
                    alert(data.msg);
                    // alert("아이디:" +data.id + "전화번호:"+ data.tel);
                    document.location.href = "/main/board.do";
                }

            },
            fail : function() {
                alert("Server Error");

            }
        });
/*        setTimeout(function (){
            document.location.href = "/main/board.do"
            $('#loading').hide();
        },3000)*/

    }


</script>
<style>
    .page-body-wrapper {
        min-height: calc(100vh - 90px)!important;
    }
</style>
<body>
<div id="loading" style="margin-left: 0px;">
    <img src="../static/images/loadingImg.gif">
    <p>로그인중입니다. 잠시만 기다려주세요.</p>
</div>
<div class="container-scroller">
    <div class="container-fluid page-body-wrapper full-page-wrapper" >
        <div class="content-wrapper d-flex align-items-center auth px-0" style="background-image: url(/static/images/main.jpg); background-size: 100%,100%;">
            <div class="row w-100 mx-0">
                <div class="col-lg-4 mx-auto">
                    <div class="auth-form-light text-left py-5 px-sm-5" style="border-radius: 10%;width: 35em;margin-left: 70px;">
                        <h4 style="font-family: SingleDay;font-size: 2.5em;">교육 개발 샘플</h4>
                        <h6 class="font-weight-light" style="font-family: SingleDay;font-size: 1em;">사내 직원만 사용이 가능합니다.</h6>
                        <form id="form" name="form" method="POST" action="/login-proc.do" class="pt-3">
                            <div class="form-group">
                                <input class="form-control" type="text" name="usId" id="usId" placeholder="ID 입력">
                            </div>
                            <div class="form-group">
                                <input class="form-control" type="password" name="usPassword" id="usPassword" onkeypress="if( event.keyCode==13 ){proc();}" placeholder="Password 입력">
                            </div>
                            <div class="mt-3">
                                <a class="btn btn-block btn-primary btn-lg font-weight-medium auth-form-btn" id="loginBtn" onclick="proc();" style="color: #fff;">로그인</a>
                                <a class="btn btn-block btn-primary btn-lg font-weight-medium auth-form-btn" id="test"  style="color: #fff;">test</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

    </div>
    <!-- page-body-wrapper ends -->
    <!-- content-wrapper ends -->
    <footer class="footer footer-alt text-center" style="font-size: 0.872em;">
        본 시스템은 (주)편강 임직원에 한하여 사용 하실 수 있습니다.<br>
        불법적인 접근 및 사용 시 관련 법규에 의해 처벌 될 수 있습니다.<br>
        <b><script>document.write(new Date().getFullYear())</script>C(주)편강</b>
    </footer>
</div>
<!-- container-scroller -->



</body>
</html>
