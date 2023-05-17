<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>

<%
	// DB 연결
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dbUser = "hr";
	String dbPw = "1234";
	String dbUrl = "jdbc:oracle:thin:@localhost:1521:xe";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println(conn + " <-- conn(test2)");
	
	/* 
	select department_id, job_id, count(*) from employees
	group by department_id, job_id;

	select department_id, job_id, count(*) from employees
	group by rollup(department_id, job_id);

	select department_id, job_id, count(*) from employees
	group by cube(department_id, job_id); -- cube(A, B): A의 소계, B의 소계, A + B의 소계, 총계
	
	*/
	
	String groupBySql = "select department_id 부서ID, job_id 직무ID, count(*) cnt from employees group by department_id, job_id";
	PreparedStatement groupByStmt = conn.prepareStatement(groupBySql);
	ResultSet groupByRs = groupByStmt.executeQuery();
	ArrayList<HashMap<String, Object>> list1 = new ArrayList<HashMap<String, Object>>();
	while (groupByRs.next()) {
		HashMap<String, Object> m1 = new HashMap<String, Object>();
		m1.put("부서ID", groupByRs.getInt("부서ID"));
		m1.put("직무ID", groupByRs.getString("직무ID"));
		m1.put("cnt", groupByRs.getInt("cnt")); // key, value alias 통일
		list1.add(m1);
	}
	System.out.println(list1);
	System.out.println(list1.size());
	
	String groupingSetsSql = "select department_id 부서ID, job_id 직무ID, count(*) cnt from employees group by grouping sets(department_id, job_id)";
	PreparedStatement groupingSetsStmt = conn.prepareStatement(groupingSetsSql);
	ResultSet groupingSetsRs = groupingSetsStmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
	while (groupingSetsRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("부서ID",	groupingSetsRs.getInt("부서ID"));
		m.put("직무ID", groupingSetsRs.getString("직무ID"));
		m.put("cnt", groupingSetsRs.getInt("cnt")); // key, value alias 통일
		list.add(m);
	}
	System.out.println(list);
	System.out.println(list.size());
	
	
	String rollUpSql = "select department_id 부서ID, job_id 직무ID, count(*) cnt from employees group by rollup(department_id, job_id)";
	PreparedStatement rollUpStmt = conn.prepareStatement(rollUpSql);
	ResultSet rollUpRs = groupByStmt.executeQuery();
	ArrayList<HashMap<String, Object>> list2 = new ArrayList<HashMap<String, Object>>();
	while (rollUpRs.next()) {
		HashMap<String, Object> m2 = new HashMap<String, Object>();
		m2.put("부서ID", rollUpRs.getInt("부서ID"));
		m2.put("직무ID", rollUpRs.getString("직무ID"));
		m2.put("cnt", rollUpRs.getInt("cnt")); // key, value alias 통일
		list2.add(m2);
	}
	System.out.println(list2);
	System.out.println(list2.size());
	
	String cubeSql = "select department_id 부서ID, job_id 직무ID, count(*) cnt from employees group by cube(department_id, job_id)";
	PreparedStatement cubeStmt = conn.prepareStatement(cubeSql);
	ResultSet cubeRs = cubeStmt.executeQuery();
	ArrayList<HashMap<String, Object>> list3 = new ArrayList<HashMap<String, Object>>();
	while (cubeRs.next()) {
		HashMap<String, Object> m3 = new HashMap<String, Object>();
		m3.put("부서ID", cubeRs.getInt("부서ID"));
		m3.put("직무ID", cubeRs.getString("직무ID"));
		m3.put("cnt", cubeRs.getInt("cnt")); // key, value alias 통일
		list3.add(m3);
	}
	System.out.println(list3);
	System.out.println(list3.size());
	
	
	System.out.println("==============================");
%>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>group_by_test2</title>
	</head>
	<body>
		<h1>GROUP BY</h1>
		<table border="1">
			<tr>
				<td>부서ID</td>
				<td>직무ID</td>
				<td>합계</td>
			</tr>
			<%
				for (HashMap<String, Object> m1 : list1) {
			%>
			<tr>
				<td><%=(Integer)m1.get("부서ID")%></td>
				<td><%=m1.get("직무ID")%></td>
				<td><%=(Integer)m1.get("cnt")%></td>
			</tr>
			<%
				}
			%>
		</table>

		<h1>GROUPING SETS</h1>
		<table border="1">
			<tr>
				<td>부서ID</td>
				<td>직무ID</td>
				<td>합계</td>
			</tr>
			<%
				for (HashMap<String, Object> m: list) {
			%>
			<tr>
				<td><%=(Integer)m.get("부서ID")%></td>
				<td><%=m.get("직무ID")%></td>
				<td><%=(Integer)m.get("cnt")%></td>
			</tr>
			<%
				}
			%>
		</table>

		<h1>ROLLUP</h1>
		<table border="1">
			<tr>
				<td>부서ID</td>
				<td>직무ID</td>
				<td>합계</td>
			</tr>
			<%
				for (HashMap<String, Object> m2: list2) {
			%>
			<tr>
				<td><%=(Integer)m2.get("부서ID")%></td>
				<td><%=m2.get("직무ID")%></td>
				<td><%=(Integer)m2.get("cnt")%></td>
			</tr>
			<%
				}
			%>
		</table>

		<h1>CUBE</h1>
		<table border="1">
			<tr>
				<td>부서ID</td>
				<td>직무ID</td>
				<td>합계</td>
			</tr>
			<%
				for (HashMap<String, Object> m3: list3) {
			%>
			<tr>
				<td><%=(Integer)m3.get("부서ID")%></td>
				<td><%=m3.get("직무ID")%></td>
				<td><%=(Integer)m3.get("cnt")%></td>
			</tr>
			<%
				}
			%>
		</table>
	</body>
</html>