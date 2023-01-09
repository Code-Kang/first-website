package kr.co.sample.controller;

import kr.co.sample.common.AdminSession;
import kr.co.sample.model.Admin;
import kr.co.sample.model.User;
import kr.co.sample.service.AdminService;
import kr.co.sample.util.CryptoUtils;
import kr.co.sample.util.HttpRequestHelper;
import kr.co.sample.util.Param;
import org.apache.commons.lang3.RandomStringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;

@Controller
public class MainController {
    @Autowired
    private AdminService adminService;

    private static final Logger logger = LogManager.getLogger(MainController.class);

    @RequestMapping("**/*.do")
    public String resolve() {
        HttpServletRequest request = HttpRequestHelper.getCurrentRequest();

        String viewName = request.getRequestURI();

        if (viewName == null)
            //정상 경로
            viewName = request.getServletPath();

        viewName = viewName.substring(viewName.indexOf('/'));
        viewName = viewName.substring(0, viewName.lastIndexOf(".do"));

        return viewName;
    }

    @RequestMapping("/login.do")
    public String index() throws Exception {
        return "/login";
    }

    @RequestMapping("/main/test.do")
    public String test() throws Exception {
        return "/main/test";
    }

    @RequestMapping("/inc/footer.do")
    public String footer() throws Exception {
        return "/inc/footer";
    }

    @RequestMapping("/inc/header.do")
    public String header(ModelMap model, HttpServletRequest request) throws Exception {
        AdminSession adminSession = AdminSession.getCurrentInstance(request);
        String name = adminSession.getAdminName(); //고객이름
        String level = adminSession.getLevel(); //등급

        model.addAttribute("name", name);
        model.addAttribute("level", level);
        model.addAttribute("usId", adminSession.getUsId());

        return "/inc/header";
    }

    @RequestMapping("/common/exists.do")
    @ResponseBody
    public boolean isExists() throws Exception {
        /***
         * 유저 확인
         */
        HttpServletRequest request = HttpRequestHelper.getCurrentRequest();
        Param param = new Param(request);

        String usId = param.get("usId");
        Admin info = adminService.adminInfo(usId);
        if(info != null){
            return true;
        }
        return false;
    }

    // 로그인 처리
    @RequestMapping("/common/userLogin.do")
    @ResponseBody
    public String userLogin(User user) throws Exception {
        HttpServletRequest request = HttpRequestHelper.getCurrentRequest();
        String encPasswd = CryptoUtils.encodeSHA512(user.getUsPassword());
        Admin loginAdmin = new Admin();
        JSONObject jsonObject = new JSONObject();
        User info = adminService.userLogin(user);

        if (info == null) {
            jsonObject.put("flg","N");
            jsonObject.put("msg","아이디 또는 비밀번호가 틀렸습니다. 로그인 실패");
        }else if (!encPasswd.equals(info.getUsPassword())) {
            adminService.updateloginFailCount(user);
            jsonObject.put("flg","N");
            jsonObject.put("msg","비밀번호가 틀렸습니다. 로그인 실패");
            jsonObject.put("failCnt",info.getLoginFailCount());
            jsonObject.put("failCntMsg","5회 이상 로그인에 실패하여, 해당 계정은 잠금처리 되었습니다.");
            return jsonObject.toString();
        }else if (encPasswd.equals(info.getUsPassword())) {
            jsonObject.put("failCnt",info.getLoginFailCount());
            jsonObject.put("failCntMsg","해당 계정은 잠금처리 되었습니다.");
            jsonObject.put("flg", "Y");
            jsonObject.put("msg", "로그인 성공");
            if (info.getLoginFailCount() < 4){
                adminService.updateTodayLogin(user);
            }
            AdminSession adminSession = AdminSession.getCurrentInstance(request);
            loginAdmin.setUsId(info.getUsId());
            adminSession.login(loginAdmin);
            return jsonObject.toString();
        }
        return jsonObject.toString();
    }

    // 아이디 중복 체크
    @RequestMapping("/common/idCheck.do")
    @ResponseBody
    public String idCheck(User user) throws Exception {
        String chId = user.getUsId();
        JSONObject jsonObject = new JSONObject();
        user.setUsId(chId);
        User idCheck = adminService.idCheck(user);

        if (idCheck == null) {
            jsonObject.put("flg", "Y");
            jsonObject.put("msg", "사용 가능한 아이디 입니다.");
            return jsonObject.toString();
        }else if (chId.equals(idCheck.getUsId())) {
            jsonObject.put("flg", "N");
            jsonObject.put("msg","중복된 아이디가 있습니다.");
            return jsonObject.toString();
        }

        return jsonObject.toString();
    }

    // 사용자 추가
    @RequestMapping(value="/common/regist_member.do")
    @ResponseBody
    public void registMember(User testPage) throws Exception {
        HttpServletRequest request = HttpRequestHelper.getCurrentRequest();
        AdminSession adminSession = new AdminSession(request);
        String registId = (adminSession.getUsId());

        String encPasswd = CryptoUtils.encodeSHA512(testPage.getUsPassword());
        testPage.setUsPassword(encPasswd);
        testPage.setRegistId(registId);
        testPage.setModifyId(registId);
        adminService.registMember(testPage);
    }


    @RequestMapping(value = "/login-proc.do", method = RequestMethod.POST)
    @ResponseBody
    public String loginProc() throws Exception {

        /***
         * 로그인 처리
         */
        HttpServletRequest request = HttpRequestHelper.getCurrentRequest();
        JSONObject jsonObject = new JSONObject();
        Param param = new Param(request);

        //기본 파라미터 체크
        if("".equals(param.get("usId"))){
            jsonObject.put("result","false");
            jsonObject.put("message","아이디를 입력해 주세요.");
            return jsonObject.toString();
        }else if("".equals(param.get("usPass"))){
            jsonObject.put("result","false");
            jsonObject.put("message","비밀번호를 입력해주세요.");
            return jsonObject.toString();
        }

        //이전 페이지 취득
        String referer = request.getHeader( "REFERER");
        if( referer == null && referer.length() < 0){
            jsonObject.put("result","false");
            jsonObject.put("message","유효하지 않은 접근입니다.");
            return jsonObject.toString();
        }

        //관리자 정보 취득
        Admin info = adminService.adminInfo(param.get("usId"));
        if(info == null){
            jsonObject.put("result","false");
            jsonObject.put("message","입력하신 정보가 일치하지 않습니다. ID 또는 비밀번호를 다시 확인해주세요.(1)");
            return jsonObject.toString();
        }

        // 계정 활성 체크
        if(!"S".equals(info.getCmAllow())){
            jsonObject.put("result","false");
            jsonObject.put("message","해당 계정은 비활성화 상태 입니다.\n담당자에게 문의 바랍니다.");
            return jsonObject.toString();
        }

        //5회 이상 로그인 실패
        if (info.getfCount() >= 5 && info.getfTime() < 30){
            jsonObject.put("result","false");
            jsonObject.put("message","5번 로그인 시도에 실패 하였습니다. "+(30 - info.getfCount())+"초 후에 다시 시도해 주세요.");
            return jsonObject.toString();
        }else if(info.getfCount() >= 5 && info.getfTime() > 30){
        }

        //비밀번호 암호화
        String passwd = param.get("usPass");
        String encPasswd = CryptoUtils.encodeSHA512(passwd);

        //회원 정보 셋팅
        Admin loginAdmin = new Admin();
        loginAdmin.setUsId(info.getUsId());
        loginAdmin.setLoginIp(HttpRequestHelper.getRequestIp());
        loginAdmin.setReferer(referer);

        // 비밀번호 체크
        if(!encPasswd.equals(info.getUsPass())){
            adminService.updateLoginFail(loginAdmin);
            jsonObject.put("result","false");
            jsonObject.put("message","입력하신 정보가 일치하지 않습니다. ID 또는 비밀번호를 다시 확인해주세요.(2)");
            return jsonObject.toString();
        }

        //비밀번호 실패 횟수 초기화 및 세션키 작성
        String loginSessionKey = CryptoUtils.encodeSHA256(RandomStringUtils.random(15));
        loginAdmin.setSessionKey(loginSessionKey);
        adminService.updateLoginInfo(loginAdmin);

        //로그 설정
        AdminSession adminSession = AdminSession.getCurrentInstance(request);
        loginAdmin.setUsId(info.getUsId());
        loginAdmin.setUsName(info.getUsName());
        loginAdmin.setSessionKey(loginSessionKey);
        loginAdmin.setLevel(info.getLevel());

        adminSession.login(loginAdmin);

        jsonObject.put("result", true);
        jsonObject.put("check", true);
        jsonObject.put("coId", info.getCoId());
        jsonObject.put("level", info.getLevel());
        jsonObject.put("usId", info.getUsId());

        return jsonObject.toString();
    }

    @RequestMapping("/logout.do")
    public String logout() throws Exception {
        /***
         * 로그아웃 처리
         */
        HttpServletRequest request = HttpRequestHelper.getCurrentRequest();
        AdminSession adminSession = AdminSession.getCurrentInstance(request);
        adminSession.logout();
        return "redirect:/login.do";
    }


    /********************************************
     * 사용자 추가 페이지 > 사용자 등록 처리
     ********************************************/
//    @RequestMapping("/common/regist_member.do")
//    public String registMember(User pageItem) throws Exception {
//        // User 모델에 jsp 필드 [name]과 동일한 변수 geter, seter 구현
//
//        // 필수 입력값 검사
//        // 아이디 검사
//
//        // 사용자 이름 검사
//
//        // 비밀번호 검사
//
//        // 비밀번호 확인 검사
//
//        // 비밀번호 = 비밀번호 확인 검사
//
//        // 전화번호 검사
//
//        // 핸드폰 번호 검사
//
//        // 이메일 검사
//
//
//
//        // DB에 사용자 등록 처리
//
//
//
//        return "";
//    }

    /********************************************
     * 사용자 추가 페이지 > 아이디 중복 검사
     ********************************************/
//    @RequestMapping("~~~~~~")
//    @ResponseBody
//    public String ~~~~~() throws Exception {
//        JSONObject jsonObject = new JSONObject();
//
//        // DB에서 아이디 검색
//        // 0건이면 중복 아님
//
//
//        return jsonObject.toString();
//    }
}
