import ballerinax/worldbank;
import ballerinax/covid19;
import ballerina/http;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function get stats/[string country]() returns json|error {

        covid19:Client covid19Endpoint = check new ({});
        covid19:CovidCountry statusByCountry = check covid19Endpoint->getStatusByCountry(country);
        int totalCases = <int>statusByCountry.cases;
        worldbank:Client worldbankEndpoint = check new ({});
        worldbank:IndicatorInformation[] populationByCountry = check worldbankEndpoint->getPopulationByCountry(country);
        int populationMillions = (populationByCountry[0]?.value ?: 0) / 1000000;
        decimal totalCasesPerMillion = <decimal>(totalCases / populationMillions);
        json payload = {country: country, totalCasesPerMillion: totalCasesPerMillion};
        return payload;
    }
}
