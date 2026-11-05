package pod.man;

import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

import javax.sql.DataSource;
import java.sql.SQLException;

@Path("/hello")
public class GreetingResource {

    private final DataSource dataSource;

    @Inject
    public GreetingResource(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
        return "Hello from Quarkus REST";
    }

    @GET
    @Path("/db")
    @Produces(MediaType.TEXT_PLAIN)
    public String toto() {
        var sb = new StringBuilder();
        try (var connection = dataSource.getConnection(); var ps = connection.prepareStatement("SELECT * FROM personnages;");
             var rs = ps.executeQuery()) {

            while (rs.next()) {
                sb.append(rs.getString(1)).append("\n");
                sb.append(rs.getString(2)).append("\n");
            }
        } catch (SQLException e) {
            sb.append("this is not happening because it boomed");
            e.printStackTrace();
        }
        return sb.toString();
    }
}
