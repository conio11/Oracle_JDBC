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
   int currentPage = 1; // 기본 1페이지 
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
   if (totalRowRs.next()) {
      totalRow = totalRowRs.getInt(1); // totalRowRs.getInt("count(*)")
   }
   
   int rowPerPage = 10;
   // BETWEEN beginRow AND endRow
   int beginRow = (currentPage - 1) * rowPerPage + 1; // 1페이지: 1, 2페이지: 11, 3페이지: 21, ...
   int endRow = beginRow + (rowPerPage - 1);
   if (endRow > totalRow) {
      endRow = totalRow;
   }
   System.out.println(endRow + " <-- endRow(functionEmpList)");
   
   String sql = "select 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도 from (select rownum 번호, last_name 이름, substr(last_name, 1, 1) 이름첫글자, salary 연봉, round(salary/12, 2) 급여, hire_date 입사날짜, extract(year from hire_date) 입사년도 from employees) where 번호 between ? and ?";
   PreparedStatement stmt = conn.prepareStatement(sql);
   stmt.setInt(1, beginRow);
   stmt.setInt(2, endRow);
   ResultSet rs = stmt.executeQuery();
   System.out.println(stmt + " <-- stmt(functionEmpList2)");
   
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

   System.out.println("===========================");
%>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>functionEmpList</title>
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
	         for (HashMap<String, Object> m : list) {
	      %>
	            <tr>
	               <td><%=(Integer)m.get("번호")%></td>
	               <td><%=(String)m.get("이름")%></td>
	               <td><%=(String)m.get("이름첫글자")%></td>
	               <td><%=(Integer)m.get("연봉")%></td>
	               <td><%=(Double)m.get("급여")%></td>
	               <td><%=(String)m.get("입사날짜")%></td>
	               <td><%=(Integer)m.get("입사년도")%></td>
	            </tr>
	      <%      
	         }
	      %>
      </table>
	   
   <%
		// 페이지 네비게이션 페이징
		int pagePerPage = 10; // [이전] [다음] 탭 사이 페이지 개수
		/* cp: currentPage
			cp  minPage ~ maxPage
			1    1 		~ 	10
			2 	 1 		~ 	10
			10 	 1 		~ 	10
			
			11 	 11		~ 	20
			12   11 	~ 	20
			20   11 	~ 	20
			
			(cp - 1) / pagePerPage * pagePerPage + 1 -> minPage
			minPage + (pagePerPage - 1) --> maxPage
			maxPage > lastPage --> maxPage = lastPage
		 */
		 
		 // lastPage: 최대 currentPage
		 // 마지막 페이지: 전체 행 수 / 페이지별 행 수 
		 int lastPage = totalRow / rowPerPage; 
		 if (totalRow % rowPerPage != 0) {
			 lastPage = lastPage + 1;
		 }
		 
		 // minPage: [이전] [다음] 탭 사이 가장 작은 숫자
		 // maxPage: [이전] [다음] 탭 사이 가장 큰 숫자
		 int minPage = ((currentPage - 1) / pagePerPage) * pagePerPage + 1;
		 int maxPage = minPage + (pagePerPage - 1);
		 if (maxPage > lastPage) { // maxPage가 마지막 페이지(최대 currentPage) 보다 클 수 없음
			 maxPage = lastPage;
		 }
		 
		 if (minPage > 1) { // 현재 페이지의 minPage가 첫 페이지의 minPage인 1보다 클 때 (여기서는 11, 21, ,,,) 이전 버튼 생성
 	%>
	 		<a href="<%=request.getContextPath()%>/functionEmpList2.jsp?currentPage=<%=minPage - pagePerPage%>">이전</a> <!-- ex) minPage가 11이면 11 - 10: 1페이지로 이동 -->
    <% 
		 }
		 
    	for (int i = minPage; i <= maxPage; i = i + 1) { // [이전] [다음] 탭 사이 반복
    		if (i == currentPage) {
    %> 
    			<span><%=i%></span> <!-- 현재 페이지(선택한 페이지) 번호를 링크 없이 표시 -->	
	<%
    		} else { // 나머지 페이지(선택되지 않은 페이지) 번호를 링크로 표시 -> 링크 클릭 시 해당 번호 페이지로 이동
	%>
	   			<a href="<%=request.getContextPath()%>/functionEmpList2.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
	   		<!-- page + 1 -->
    <%	 
    		}
    	}
    	
    	if (maxPage < lastPage) { // [이전] [다음] 탭 사이 가장 큰 숫자가 마지막 페이지와 다르면 다음 버튼 생성 
    %>
	   		<a href="<%=request.getContextPath()%>/functionEmpList2.jsp?currentPage=<%=minPage + pagePerPage%>">다음</a> <!-- ex) minPage가 1이면 1 + 10: 11페이지로 이동  -->
	<%
    	}
	%>
	</body>
</html>