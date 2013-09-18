

function KmerAnnotationByFigfam(url, auth, auth_cb) {

    var _url = url;

    if (typeof(_url) != "string" || _url.length == 0)
    {
	_url = "http://10.0.16.184:7105";
    }
    var _auth = auth ? auth : { 'token' : '',
                                'user_id' : ''};
    var _auth_cb = auth_cb;


    this.get_dataset_names = function()
    {
        var resp = json_call_ajax_sync("KmerAnnotationByFigfam.get_dataset_names", []);

        return resp[0];
    }

    this.get_dataset_names_async = function(_callback, _error_callback)
    {
        json_call_ajax_async("KmerAnnotationByFigfam.get_dataset_names", [], 1, _callback, _error_callback)
    }

    this.get_default_dataset_name = function()
    {
        var resp = json_call_ajax_sync("KmerAnnotationByFigfam.get_default_dataset_name", []);

        return resp[0];
    }

    this.get_default_dataset_name_async = function(_callback, _error_callback)
    {
        json_call_ajax_async("KmerAnnotationByFigfam.get_default_dataset_name", [], 1, _callback, _error_callback)
    }

    this.annotate_proteins = function(proteins, params)
    {
        var resp = json_call_ajax_sync("KmerAnnotationByFigfam.annotate_proteins", [proteins, params]);

        return resp[0];
    }

    this.annotate_proteins_async = function(proteins, params, _callback, _error_callback)
    {
        json_call_ajax_async("KmerAnnotationByFigfam.annotate_proteins", [proteins, params], 1, _callback, _error_callback)
    }

    this.annotate_proteins_fasta = function(protein_fasta, params)
    {
        var resp = json_call_ajax_sync("KmerAnnotationByFigfam.annotate_proteins_fasta", [protein_fasta, params]);

        return resp[0];
    }

    this.annotate_proteins_fasta_async = function(protein_fasta, params, _callback, _error_callback)
    {
        json_call_ajax_async("KmerAnnotationByFigfam.annotate_proteins_fasta", [protein_fasta, params], 1, _callback, _error_callback)
    }

    /*
     * JSON call using jQuery method.
     */

    function json_call_ajax_sync(method, params)
    {
        var rpc = { 'params' : params,
                    'method' : method,
                    'version': "1.1",
                    'id': String(Math.random()).slice(2),
        };
        
        var body = JSON.stringify(rpc);
        var resp_txt;
        var code;

	var token = _auth.token;
	if (_auth_cb)
	{
	    token = _auth_cb();
	}

        var x = jQuery.ajax({
		"async": false,
		dataType: "text",
		url: _url,
		beforeSend: function (xhr){
		    if (token)
		    {
			xhr.setRequestHeader('Authorization', _auth.token);
		    }
		},
		success: function (data, status, xhr) { resp_txt = data; code = xhr.status },
		error: function(xhr, textStatus, errorThrown) { resp_txt = xhr.responseText, code = xhr.status },
		data: body,
		processData: false,
		type: 'POST',
	    });

        var result;

        if (resp_txt)
        {
            var resp = JSON.parse(resp_txt);
            
            if (code >= 500)
            {
                throw resp.error;
            }
            else
            {
                return resp.result;
            }
        }
        else
        {
            return null;
        }
    }

    function json_call_ajax_async(method, params, num_rets, callback, error_callback)
    {
        var rpc = { 'params' : params,
                    'method' : method,
                    'version': "1.1",
                    'id': String(Math.random()).slice(2),
        };
        
        var body = JSON.stringify(rpc);
        var resp_txt;
        var code;
        
	var token = _auth.token;
	if (_auth_cb)
	{
	    token = _auth_cb();
	}

        var x = jQuery.ajax({
		"async": true,
		dataType: "text",
		url: _url,
		beforeSend: function (xhr){
		    if (token)
		    {
			xhr.setRequestHeader('Authorization', token);
		    }
		},
		success: function (data, status, xhr)
		{
		    resp = JSON.parse(data);
		    var result = resp["result"];
		    if (num_rets == 1)
		    {
			callback(result[0]);
		    }
		    else
		    {
			callback(result);
		    }
                    
		},
		error: function(xhr, textStatus, errorThrown)
		{
		    if (xhr.responseText)
		    {
			resp = JSON.parse(xhr.responseText);
			if (error_callback)
			{
			    error_callback(resp.error);
			}
			else
			{
			    throw resp.error;
			}
		    }
		},
		data: body,
		processData: false,
		type: 'POST',
	    });
    }
}


