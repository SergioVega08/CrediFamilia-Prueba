global with sharing class LeadWebService {
    webService static ResponseWrapper ingresar_lead(String nombres, String apellidos, String email, String telefono, String numeroDocumento, String tipoDocumento, String ciudad) {
        ResponseWrapper response = new ResponseWrapper();
        
        List<Lead> existingLeads = [SELECT Id, Status
                                    FROM Lead 
                                    WHERE numero_de_documento__c = :numeroDocumento 
                                      AND Tipo_de_documento__c = :tipoDocumento
                                    LIMIT 1];

        if (existingLeads.isEmpty()) {
            // Crear lead nuevo
            Lead newLead = new Lead(FirstName = nombres, LastName = apellidos, Email = email,
                                    Phone = telefono, numero_de_documento__c = numeroDocumento,
                                    Tipo_de_documento__c = tipoDocumento, ciudad__c = ciudad,
                                    Company = 'EmpresaX');
            insert newLead;
            response.codigo = '00';
            response.id = newLead.Id;
        } else {
            Lead lead = existingLeads[0];
            if (lead.Status == 'Closed - Converted') {
                response.codigo = '04';
                response.id = lead.Id;
            } else if (lead.Status == 'Closed - Not Converted' ) {
                response.codigo = '01';
                response.id = lead.Id;
            } else {
                // Actualizar lead
                lead.FirstName = nombres;
                lead.LastName = apellidos;
                lead.Email = email;
                lead.Phone = telefono;
                lead.ciudad__c = ciudad;
                update lead;
                
                // Notificar asesor y crear tarea
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] {'asergio.98@gmail.com'});
                mail.setSubject('Lead Actualizado');
                mail.setPlainTextBody('El lead ha sido actualizado: ' + lead.Id);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                
                Task tarea = new Task(Subject = 'Seguimiento lead actualizado',
                                      ActivityDate = Date.today(),
                                      OwnerId = UserInfo.getUserId());
                insert tarea;
                response.codigo = '03';
                response.id = lead.Id;
            }
        }
        
        return response;
    }

    global class ResponseWrapper {
        webService String codigo;
        webService Id id;
    }
}
