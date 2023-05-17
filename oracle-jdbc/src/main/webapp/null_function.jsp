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
	System.out.println(conn + " <-- conn(null)");
	
	String nvlSql = "select 이름, nvl(일분기, 0) nvl from 실적";
	PreparedStatement nvlStmt = conn.prepareStatement(nvlSql);
	ResultSet nvlRs = nvlStmt.executeQuery();
	ArrayList<HashMap<String, Object>> list1 = new ArrayList<HashMap<String, Object>>();
	while (nvlRs.next()) {
		HashMap<String, Object> m1 = new HashMap<String, Object>();
		m1.put("이름", nvlRs.getString("이름"));
		m1.put("nvl", nvlRs.getInt("nvl"));
		list1.add(m1);
	}
	System.out.println(list1);
	System.out.println(list1.size());
	
	String nvl2Sql = "select 이름, nvl2(일분기, 'success', 'fail') nvl2 from 실적";
	PreparedStatement nvl2Stmt = conn.prepareStatement(nvl2Sql);
	ResultSet nvl2Rs = nvl2Stmt.executeQuery();
	ArrayList<HashMap<String, Object>> list2 = new ArrayList<HashMap<String, Object>>();
	while (nvl2Rs.next()) {
		HashMap<String, Object> m2 = new HashMap<String, Object>();
		m2.put("이름", nvl2Rs.getString("이름"));
		m2.put("nvl2", nvl2Rs.getString("nvl2"));
		list2.add(m2);
	}
	System.out.println(list2);
	System.out.println(list2.size());
	
	String nullIfSql = "select 이름, nullif(사분기, 100) nullif from 실적";
	PreparedStatement nullIfStmt = conn.prepareStatement(nullIfSql);
	ResultSet nullIfRs = nullIfStmt.executeQuery();
	ArrayList<HashMap<String, Object>> list3 = new ArrayList<HashMap<String, Object>>();
	while (nullIfRs.next()) {
		HashMap<String, Object> m3 = new HashMap<String, Object>();
		m3.put("이름", nullIfRs.getString("이름"));
		m3.put("nullif", nullIfRs.getInt("nullif"));
		list3.add(m3);
	}
	System.out.println(list3);
	System.out.println(list3.size());
	
	String coalescelSql = "select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) coalesce from 실적";
	PreparedStatement coalesceStmt = conn.prepareStatement(coalescelSql);
	ResultSet coalesceRs = coalesceStmt.executeQuery();
	ArrayList<HashMap<String, Object>> list4 = new ArrayList<HashMap<String, Object>>();
	while (coalesceRs.next()) {
		HashMap<String, Object> m4 = new HashMap<String, Object>();
		m4.put("이름", coalesceRs.getString("이름"));
		m4.put("coalesce", coalesceRs.getInt("coalesce"));
		list4.add(m4);
	}
	System.out.println(list4);
	System.out.println(list4.size());
	
	System.out.println("==============================");
%>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>NULL function</title>
	</head>
	<body>
		<h1>NVL</h1>
		<table border="1">
			<tr>
				<td>이름</td>
				<td>결과</td>
			</tr>
			<%
				for (HashMap<String, Object> m1 : list1) {
			%>
			<tr>
				<td><%=m1.get("이름")%></td>
				<td><%=(Integer)m1.get("nvl")%></td>
			</tr>
			<%
				}
			%>
		</table>
		
		<h1>NVL2</h1>
		<table border="1">
			<tr>
				<td>이름</td>
				<td>결과</td>
			</tr>
			<%
				for (HashMap<String, Object> m2 : list2) {
			%>
			<tr>
				<td><%=m2.get("이름")%></td>
				<td><%=m2.get("nvl2")%></td>
			</tr>
			<%
				}
			%>
		</table>
		
		<h1>NULLIF</h1>
		<table border="1">
			<tr>
				<td>이름</td>
				<td>결과</td>
			</tr>
			<%
				for (HashMap<String, Object> m3 : list3) {
			%>
			<tr>
				<td><%=m3.get("이름")%></td>
				<td><%=(Integer)m3.get("nullif")%></td>
			</tr>
			<%
				}
			%>
		</table>
		
		<h1>COALESCE</h1>
		<table border="1">
			<tr>
				<td>이름</td>
				<td>결과</td>
			</tr>
			<%
				for (HashMap<String, Object> m4 : list4) {
			%>
			<tr>
				<td><%=m4.get("이름")%></td>
				<td><%=(Integer)m4.get("coalesce")%></td>
			</tr>
			<%
				}
			%>
		</table>
	</body>
</html>