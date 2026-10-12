package pe.edu.upc;

import io.karatelabs.core.Runner;
import io.karatelabs.core.SuiteResult;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class TestRunner {

    @Test
    public void testAll() {
        // Corre los archivos .feature en el paquete 'pe/edu/upc'
        SuiteResult result = Runner.path("classpath:pe/edu/upc")
                .outputHtmlReport(true)
                .parallel(5);

        assertTrue(result.isPassed(), "Existen pruebas fallidas en Karate");
    }
}