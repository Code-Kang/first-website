<%------------------------------------------------------------
    사용자 추가 페이지
------------------------------------------------------------%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:import url="/inc/header.do" />
<jsp:useBean id="Utils" class="kr.co.sample.util.Utils"/>
<!-- ============================================================== -->
<!-- Start Page Content here -->
<!-- ============================================================== -->
<script type="text/javascript">
    var idchval = 0;
    $(function(){
        // 로딩 숨기기
        $("#loading").hide();

        /********************************
         * 아이디 중복 확인 버튼
         ********************************/

        $('#duplication').off('click').on('click', function () {
            // 아이디 중복 검사 처리
            // MainController 에 아이디 중복 처리 구현
            var formData = $('#writeForm').serialize();
            var id = $('#usId').val();
            var regId = /^[0-9a-z]+$/;

            if(id.search(/\s/) != -1) {
                alert("아이디는 공백 없이 입력해주세요.")
                $('#usId').focus();
                return;
            }else if (false === regId.test(id)){
                alert("아이디는 영문, 숫자만 사용 가능합니다.")
                $('#usId').focus();
                return;
            }

            $.ajax({
                type : "POST",
                url : "/common/idCheck.do",
                data :formData,
                dataType : "json",
                async : false,
                success : function(data) {
                    if(data.flg == "N"){
                        $('#usId').focus();
                        alert(data.msg);
                    }else{
                        alert(data.msg);
                        idchval = 1
                    }

                },
                fail : function() {
                    alert("Server Error");

                }
            });

            // $("idDuplicationCheck").val("1");로 하는게 처리 용의
            document.writeForm.idDuplicationCheck.value = "1";

        });



        /********************************
         * 사용자 등록 버튼
         ********************************/
        $('#regist').off('click').on('click', function () {
            // 필수 입력값 검사
            // ex)
            // 아이디 검사
            var pw = $('#usPassword').val();
            var name = $('#usName').val();
            var email = $('#usEmail').val();
            var hp = $('#usHp').val()
            var tel = $('#usTel').val()
            var num = pw.search(/[0-9]/g);
            var eng = pw.search(/[a-z]/g);
            var bEng = pw.search(/[A-Z]/g);
            var spe = pw.search(/[`~!@@#$%^&*|₩₩₩'₩";:₩/?]/gi);
            var regName = /^[가-힣a-zA-Z]+$/;
            var regEmail = /^[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*\.[a-zA-Z]{2,3}$/i;
            var regTel = /^[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}$/i;
            var regHp = /^[0-9]{3}-[0-9]{4}-[0-9]{4}$/i;

            if (!!!$('#usId').val()) {
                alert("아이디를 입력해 주세요.");
                $('#usId').focus();
                return;
            } else if ($('#usName').val() == "") {
                alert("이름을 입력해 주세요.");
                $('#usName').focus();
                return;
            } else if ($('#usPassword').val() == "") {
                alert("비밀번호를 입력해 주세요.");
                $('#usPassword').focus();
                return;
            } else if ($('#usPasswordConfirm').val() == "") {
                alert("비밀번호 확인을 입력해 주세요.");
                $('#usPasswordConfirm').focus();
                return;
            } else if ($('#usPassword').val() != $("#usPasswordConfirm").val()) {
                alert("비밀번호를 동일하게 입력해 주세요.");
                $('#usPassword').focus();
                return;
            } else if ($('#usTel').val() == "") {
                alert("전화번호를 입력해 주세요.");
                $('#usTel').focus();
                return;
            } else if ($('#usHp').val() == "") {
                alert("핸드폰 번호를 입력해 주세요.");
                $('#usHp').focus();
                return;
            } else if ($('#usEmail').val() == "") {
                alert("이메일을 입력해 주세요.");
                $('#usEmail').focus();
                return;
            } else if ($('select[name=status]').val() == "") {
                alert("상태를 선택해 주세요.");
                $('#status').focus();
                return;
            } else if (writeForm.idDuplicationCheck.value == "0") {
                alert("아이디 중복확인을 해주세요.");
                $('#duplication').focus();
                return;
            } else if (false === regName.test(name)) {
                alert("잘못된 이름 입니다.")
                $('#usName').focus();
                return;
            } else if (pw.search(/\s/) != -1) {
                alert("비밀번호는 공백 없이 입력해주세요.")
                $('#usPassword').focus();
                return;
            } else if ((num < 0 && eng < 0 && bEng < 0) || (num < 0 && eng < 0 && spe < 0) || (num < 0 && bEng && spe < 0) || (eng < 0 && bEng < 0 && spe < 0)) {
                alert("비밀번호는 대문자, 소문자, 숫자, 특수문자들중 최소한 2가지 항목이 포함되어야합니다.")
                $('#usPassword').focus();
                return;
            } else if (false === regTel.test(tel)) {
                alert("잘못된 전화번호 입니다.")
                $('#usTel').focus();
                return;
            } else if (false === regHp.test(hp)) {
                alert("잘못된 핸드폰 번호 입니다.")
                $('#usHp').focus();
                return;
            } else if (false === regEmail.test(email)) {
                alert("잘못된 이메일 주소입니다.")
                $('#usEmail').focus();
                return;
            }


            // 사용자 이름 검사

            // 비밀번호 검사

            // 비밀번호 확인 검사

            // 비밀번호 = 비밀번호 확인 검사

            // 전화번호 검사

            // 핸드폰 번호 검사

            // 이메일 검사



            // 사용자 등록 처리
            // MainController 에 "/common/regist_member.do" 로 writeForm 값 전달

            $.ajax({
                type : "POST",
                url : "/common/regist_member.do",
                data : $('#writeForm').serialize(),
                dataType : "text",
                async : false,
                success : function() {
                    alert("사용자 추가가 완료 되었습니다.")
                    document.location.href = "/main/board.do";
                },
                fail : function() {
                    alert("Server Error");
                }
            });
        });



        /********************************
         * 취소 버튼
         ********************************/
        $('#cancel').off('click').on('click', function () {
            document.location.href = "/main/board.do";
            // 취소 처리
            // 이전 /main/board.jsp 페이지로 이동 !!

        });

    });

    function inputId(){
        // $("idDuplicationCheck").val("1");로 하는게 처리 용의
        document.writeForm.idDuplicationCheck.value = "0";
    }


</script>
<style>

</style>

<!-- partial -->
<div class="main-panel max_height">
    <div class="content-wrapper">
        <!-- 페이지 타이틀 시작 -->
        <div class="dashboard-header d-flex flex-column">
            <div class="d-flex align-items-center justify-content-between flex-wrap border-bottom pb-3 mb-3">
                <div class="d-flex align-items-center">
                    <h4 class="mb-0 font-weight-bold">사용자 추가</h4>
                </div>
            </div>
        </div>
        <!-- 페이지 타이틀 끝 -->
        <!-- 사용자 입력 폼 시작 -->
        <form name="writeForm" id="writeForm" method="post">
            <div class="card">
                <div class="card-body row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="usId">아이디</label>
                            <div class="d-flex">
                                <input type="text" class="form-control" name="usId" id="usId" value="" placeholder="아이디" maxlength="20" tabindex="1" autocomplete="off" onkeydown="inputId()">
                                <button type="button" class="btn btn-outline-success waves-effect waves-light ml-4" id="duplication">중복확인</button>
                                <input type="hidden" name="idDuplicationCheck" id="idDuplicationCheck" value="0" />
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="usPassword">비밀번호</label>
                            <input type="password" class="form-control" name="usPassword" id="usPassword" value="" placeholder="비밀번호는 대문자, 소문자, 숫자, 특수문자들중 최소한 2가지 항목이 포함되어야합니다." maxlength="30" tabindex="3" autocomplete="new-password">
                        </div>
                        <div class="form-group">
                            <label for="usTel">전화번호</label>
                            <input type="text" class="form-control" name="usTel" id="usTel" value="" placeholder="전화번호(ex. 02-0000-0000)" maxlength="15" tabindex="5" autocomplete="off">
                        </div>
                        <div class="form-group">
                            <label for="usEmail">이메일</label>
                            <input type="text" class="form-control" name="usEmail" id="usEmail" value="" placeholder="이메일" maxlength="50" tabindex="7" autocomplete="off">
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="usName">이름</label>
                            <input type="text" class="form-control" name="usName" id="usName" value="" placeholder="이름" maxlength="10" tabindex="2" autocomplete="off">
                        </div>
                        <div class="form-group">
                            <label for="usPasswordConfirm">비밀번호 확인</label>
                            <input type="password" class="form-control" name="usPasswordConfirm" id="usPasswordConfirm" value=""  placeholder="비밀번호 확인" maxlength="30" tabindex="4" autocomplete="new-password">
                        </div>
                        <div class="form-group">
                            <label for="usHp">핸드폰 번호</label>
                            <input type="text" class="form-control" name="usHp" id="usHp" value=""  placeholder="핸드폰 번호(ex. 010-0000-0000)" maxlength="13" tabindex="6" autocomplete="off">
                        </div>
                        <div class="form-group">
                            <label>상태</label><br>
                            <select class="custom-select" name="status" id="status" tabindex="8">
                                <option value="">선택</option>
                                <option value="S">활성화</option>
                                <option value="H">비활성화</option>
                            </select>
                        </div>
                    </div>
                    <div class="m-auto">
                        <button type="button" class="btn btn-outline-success waves-effect waves-light m-2" id="regist" style="width: 200px">등록</button>
                        <button type="button" class="btn btn-outline-info waves-effect waves-light m-2 ml-5" id="cancel" style="width: 200px">취소</button>
                    </div>
                </div>
            </div>
        </form>
        <!-- 사용자 입력 폼 끝 -->
    </div>
</div>
<!-- main-panel ends -->
<c:import url="/inc/footer.do" />
