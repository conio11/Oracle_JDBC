<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>     
<%
	// 페이징
	int currentPage = 1; // 기본 1페이지
	if (request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	System.out.println(currentPage + " <-- currentPage(exists)");
	
	// DB 연결
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dbUser = "hr";
	String dbPw = "1234";
	String dbUrl = "jdbc:oracle:thin:@localhost:1521:xe";
	Class.forName(driver);
	System.out.println("드라이버 로딩 성공(exists)");
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println("DB 접속 성공(exists)");

	// 출력할 전제 행 수 구하기
	int totalRow = 0;
	String totalRowSql = "SELECT COUNT(*) FROM employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if (totalRowRs.next()) {
		totalRow = totalRowRs.getInt(1); // 구하는 행이 한 개이므로 인덱스 사용 가능
	}
	System.out.println(totalRow + " <-- totalRow(exists)");
	
	// 페이지 당 10개 행씩 출력
	int rowPerPage = 10;

	// BETWEEN beginRow AND endRod -> endRow가 전체 행 수 (totalRow) 보다 클 수 없음
	// 1페이지: 1 ~ 10행, 2페이지: 11 ~ 20행, 3페이지: 21 ~ 30행, ...
	int beginRow = (currentPage - 1) *  rowPerPage + 1;
	int endRow = beginRow + (rowPerPage - 1);
	if (endRow > totalRow) {
		endRow = totalRow;
	}
	System.out.println(beginRow + " <-- beginRow(exists)");
	System.out.println(endRow + " <-- endRow(exists)");

	// 마지막 페이지
	int lastPage = totalRow / rowPerPage;
	if (totalRow % rowPerPage != 0) {
		lastPage++;
	}
	System.out.println(lastPage + " <-- lastPage(exists)");

	// [이전] [다음] 탭 사이 출력할 번호의 개수
	int pagePerPage = 10;
	
	// minPage: [이전] [다음] 탭 사이 번호 중 최소값 -> 1, 11, 21, ...
	// maxPage: [이전] [다음] 탭 사이 번호 중 최대값 -> 10, 20, 30, ...
	int minPage = ((currentPage - 1) / pagePerPage) * pagePerPage + 1;
	int maxPage = minPage + (pagePerPage - 1);
	if (maxPage > lastPage) { // maxPage가 마지막 페이지보다 클 수 없음
		maxPage = lastPage;
	}
	
	/*
	select 번호, 사원ID, 이름
	from
		(select rownum 번호, e.employee_id 사원ID, e.first_name 이름
			from employees e 
			where exists (select * from departments d where d.department_id = e.department_id))
	where 번호 between ? and ?
	*/
	
	String sql = "select 번호, 사원ID, 이름 from (select rownum 번호, e.employee_id 사원ID, e.first_name 이름 from employees e where exists (select * from departments d where d.department_id = e.department_id)) where 번호 between ? and ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, beginRow);
	stmt.setInt(2, endRow);
	ResultSet rs = stmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while (rs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("번호", rs.getInt("번호"));
		m.put("사원ID", rs.getInt("사원ID"));
		m.put("이름", rs.getString("이름"));
		list.add(m);
	}
	System.out.println(list.size() + " <-- list.size()(exists)");
%>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>exists_not_exists_list</title>
	</head>
	<body>
		<h1>exists_not_exists_list</h1>
		<table border="1">
			<tr>
				<th>번호</th>
				<th>사원ID</th>
				<th>이름</th>
			</tr>
		<%
			for (HashMap<String, Object> m : list) {
		%>
			<tr>
				<td><%=m.get("번호")%></td>
				<td><%=m.get("사원ID")%></td>
				<td><%=m.get("이름")%></td>
			</tr>
		<%
			}
		%>
		</table>
		
		<%		
			// 페이징
			// [이전] 1, 2, 3 ~ ... 10 [다음]
			if (minPage > 1) { // 현재 페이지의 minPage가 첫 페이지의 minPage인 1보다 클 때 (11, 21, ...)
		%>
		
			<a href="<%=request.getContextPath()%>/exists_not_exists_list.jsp?currentPage=<%=minPage - pagePerPage%>">이전</a>
		<%
			}
		
		for (int i = minPage; i <= maxPage; i+= 1) { // [이전] [다음] 탭 사이 반복
			
			if (i == currentPage) {
		%>
				<span><%=i%></span>
		<% 		
			} else { // 선택되지 않은 나머지 페이지에는 번호를 링크로 표시 (클릭 시 해당 번호 페이지로 이동)
		%>
				<a href="<%=request.getContextPath()%>/exists_not_exists_list.jsp?currentPage=<%=i%>"><%=i%></a>
		<%			
			}
		}
		
			if (maxPage < lastPage) { // [이전] [다음] 탭 사이 가장 큰 숫자가 마지막 페이지보다 작을 때만 [다음] 버튼 생성
		%>
			<a href="<%=request.getContextPath()%>/exists_not_exists_list.jsp?currentPage=<%=minPage + pagePerPage%>">다음</a>
		<% 		
		}
		%>
	</body>
</html>