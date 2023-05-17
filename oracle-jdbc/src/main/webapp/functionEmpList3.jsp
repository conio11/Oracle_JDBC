<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
/*
select 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도 
from
    (select rownum 번호, last_name 이름, substr(last_name, 1, 1) 이름첫글자, salary 연봉, round(salary/12, 2) 급여, hire_date 입사날짜, extract(year from hire_date) 입사년도 
    from employees)
where 번호 between 11 and 20;
*/
   int currentPage = 1;
   if(request.getParameter("currentPage") != null) {
      currentPage = Integer.parseInt(request.getParameter("currentPage"));
   }
   
   String driver = "oracle.jdbc.driver.OracleDriver";
   String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
   String dbuser = "hr";
   String dbpw = "1234";
   Class.forName(driver);
   Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
   System.out.println(conn);
   
   int totalRow = 0;
   String totalRowSql = "select count(*) from employees";
   PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
   ResultSet totalRowRs = totalRowStmt.executeQuery();
   if(totalRowRs.next()) {
      totalRow = totalRowRs.getInt(1); // totalRowRs.getInt("count(*)")
   }
   
   int rowPerPage = 10;
   int beginRow = (currentPage-1) * rowPerPage + 1;
   int endRow = beginRow + (rowPerPage - 1);
   if(endRow > totalRow) {
      endRow = totalRow;
   }
   
   String sql = "select 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도 from (select rownum 번호, last_name 이름, substr(last_name, 1, 1) 이름첫글자, salary 연봉, round(salary/12, 2) 급여, hire_date 입사날짜, extract(year from hire_date) 입사년도 from employees) where 번호 between ? and ?";
   PreparedStatement stmt = conn.prepareStatement(sql);
   stmt.setInt(1, beginRow);
   stmt.setInt(2, endRow);
   ResultSet rs = stmt.executeQuery();
   
   ArrayList<HashMap<String, Object>> list = new ArrayList<>();
   while(rs.next()) {
      HashMap<String, Object> m = new HashMap<String, Object>();
      m.put("번호", rs.getInt("번호"));
      m.put("이름", rs.getString("이름"));
      m.put("이름첫글자", rs.getString("이름첫글자"));
      m.put("연봉", rs.getInt("연봉"));
      m.put("급여", rs.getDouble("급여"));
      m.put("입사날짜", rs.getString("입사날짜"));
      m.put("입사년도", rs.getInt("입사년도"));
      list.add(m);
   }
   System.out.println(list.size() + " <- list.size()");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
   <table border="1">
      <tr>
         <td>번호</td>
         <td>이름</td>
         <td>이름첫글자</td>
         <td>연봉</td>
         <td>급여</td>
         <td>입사날짜</td>
         <td>입사년도</td>
      </tr>
      <%
         for(HashMap<String, Object> m : list) {
      %>
            <tr>
               <td><%=(Integer)(m.get("번호"))%></td>
               <td><%=(String)(m.get("이름"))%></td>
               <td><%=(String)(m.get("이름첫글자"))%></td>
               <td><%=(Integer)(m.get("연봉"))%></td>
               <td><%=(Double)(m.get("급여"))%></td>
               <td><%=(String)(m.get("입사날짜"))%></td>
               <td><%=(Integer)(m.get("입사년도"))%></td>
            </tr>
      <%      
         }
      %>
   </table>
   
   <%
      
      /*   cp   minPage ~ maxPage
         1      1   ~   10
         2      1   ~   10
         10      1   ~   10
         
         11      11   ~   20
         12      11   ~   20
         20      11   ~   20
         
         (cp-1) / pagePerPage * pagePerPage + 1 --> minPage
         minPage + (pagePerPage-1)  --> maxPage
         maxPage > lastPage  --> maxPage = lastPage
      */
      
      int lastPage = totalRow / rowPerPage;
      if(totalRow % rowPerPage != 0) {
         lastPage = lastPage + 1;
      }
      
      // 페이지 네비게이션 페이징
      int pagePerPage = 10;
      
      int minPage = (((currentPage-1) / pagePerPage) * pagePerPage) + 1;
      int maxPage = minPage + (pagePerPage - 1);
      if(maxPage > lastPage) {
         maxPage = lastPage;
      }
      
      if(minPage > 1) {
   %>
         <a href="<%=request.getContextPath()%>/functionEmpList3.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>   
   <%
      }
      
      for(int i = minPage; i<=maxPage; i=i+1) {
         if(i == currentPage) {
   %>
            <span><%=i%></span>&nbsp;
   <%         
         } else {      
   %>
            <a href="./functionEmpList3.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;   
   <%   
         }
      }
      
      if(maxPage != lastPage) {
   %>
         <!--  maxPage + 1 -->
         <a href="./functionEmpList3.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
   <%
      }
   %>
</body>
</html>