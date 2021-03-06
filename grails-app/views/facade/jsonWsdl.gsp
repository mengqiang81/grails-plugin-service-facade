<%@ page import="org.nofdev.servicefacade.FacadeApi; java.lang.reflect.Method; org.apache.commons.logging.LogFactory; org.apache.commons.logging.Log" contentType="text/javascript;charset=UTF-8" %>/*<%
    Log log = LogFactory.getLog("grails.app.view")
    HashSet<String> set = new HashSet<String>()
    def newLine = System.getProperty('line.separator')
    def regPackage = { name, regParent ->
        if (name == null || name.equals("")) return ""
        String packageDef = ""
        String[] parts = name.split("\\.")
        if(!set.contains(name)) {
            set.add(name)
            if (parts.length == 1) return "var $name = {};$newLine"
            int level = parts.length-2
            String parent = parts[0..level].join(".")
            if (!set.contains(parent)){
                packageDef += regParent(parent, regParent)
            }
            packageDef += "$name = {};$newLine"
        }
        packageDef
    }
    def defPackage = { name -> out.write(regPackage(name, regPackage)) }
    def escapeJSKeywords = { word ->
        if(word in ["delete"]){
            "\"$word\""
        }
        else word
    }
%>*/
<g:each in="${services}" var="srv"><% defPackage(srv.package.name) %>
${srv.name} = {<g:each in="${srv.methods}" status="i"
                           var="method"><% FacadeApi serviceApi = method.annotations.find {it instanceof FacadeApi}; if (serviceApi == null) throw new java.lang.NullPointerException("serviceApi is null, did you forget to add @FacadeApi to service method(${srv.name}.${method.name})?"); %>
    ${escapeJSKeywords(method.name)}: function(${serviceApi.params().join(', ')}){
        var params = [${serviceApi.params().join(', ')}];
        var rsl;
        $.ajax({
            type: "${method.name.startsWith('get')?'GET':'POST'}",
            url: "${baseUrl}/facade/json/${srv.package.name}/${srv.simpleName[0..-7]}/${method.name}",
            data: {"params": JSON.stringify(params)},
            dataType: "json",
            async: false,
            success: function(data) {
                rsl = data;
            },
            error: function(o){
                rsl = o;
            }
        });
        if(rsl.err) throw rsl.err;
        return rsl.val;
    }${i==srv.methods.length-1?'':','}</g:each>
};
</g:each>