<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%> 
<%
	/*  
select 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도
from 
    (select rownum 번호, last_name 이름, substr(last_name, 1, 1) 이름첫글자, salary 연봉, round(salary/12, 2) 급여, hire_date 입사날짜, extract(year from hire_date) 입사년도 
    from employees)
where 번호 between 11 and 20;
	*/
	int currentPage = 1; 
	if (request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	// DB 연결
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dbUser = "hr";
	String dbPw = "1234";
	String dbUrl = "jdbc:oracle:thin:@localhost:1521:xe";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println(conn + " <-- conn(functionEmpList))");
	
	int totalRow = 0;
	String totalRowSql = "select count(*) from employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if (totalRowRs.next()) {
		totalRow = totalRowRs.getInt(1); // totalRowRs.getInt("count(*)");
	}
	System.out.println(totalRow + " <-- totalRow(functionEmpList)");
	
	int rowPerPage = 10;
	int beginRow = (currentPage - 1) * rowPerPage + 1; 
	int endRow = beginRow + (rowPerPage - 1);
	
	if (endRow > totalRow) {
		endRow = totalRow;
	}
	System.out.println(endRow + " <-- endRow(functionEmpList)");
	
	String sql = "select 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도 from (select rownum 번호, last_name 이름, substr(last_name, 1, 1) 이름첫글자, salary 연봉, round(salary/12, 2) 급여, hire_date 입사날짜, extract(year from hire_date) 입사년도 from employees) where 번호 between ? and ?;";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, beginRow);
	stmt.setInt(2, endRow);
	ResultSet rs = stmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> list = new ArrayList<>(); // <> 내부 생략 가능
	while (rs.next()) {
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
	System.out.println(list.size() + " <-- list.size()()");
	
	System.out.println("===========================");
%>        
    
<!DOCTYPE html>
<html>
	<head>
	<meta charset="UTF-8">
	<title></title>
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
	</body>
</html>