<!---------------------------- 
        Init Vars              
------------------------------>
<cfset componentDirectory = ExpandPath("/CustomFunctions")>
<cfset functions = []>
<cfset component = "">
<!---------------------------- 
        END Init Vars          
------------------------------> 

<!---------------------------- 
    Form Submitted Section     
------------------------------> 
<cfif IsDefined("URL.component") AND directoryExists(componentDirectory)>

    <cfset component = URL.component>
    <cfset filePath = ListAppend(componentDirectory, component, "/")>

    <cfif FileExists(filePath)>

        <cffile action="read" file="#filePath#" variable="fileRead" />

        <cfset functions = []>

        <cfset startfuncreg = "<cffunction([^>]*)>">
        <cfset namereg = "name[ ]*=[ ]*""([^""]*)""">
        <cfset hintreg = "hint[ ]*=[ ]*""([^""]*)""">
        <cfset rettypereg = "returntype[ ]*=[ ]*""([^""]*)""">
        <cfset typereg = "type[ ]*=[ ]*""([^""]*)""">
        <cfset reqreg = "required[ ]*=[ ]*""([^""]*)""">
        <cfset defreg = "default[ ]*=[ ]*""([^""]*)""">
        <cfset argreg = "<cfargument([^>]*)>">
        <cfset endfuncreg = "</cffunction>">

        <cfset find = 1>

        <cfloop condition="find GT 0">
            <cfset search = reFindNoCase(startfuncreg, fileRead, find, true)>

            <cfif ArrayLen(search.len) GT 1 AND ArrayLen(search.pos) GT 1>

                <cfset functionblock = mid(fileRead, search.pos[2], search.len[2])>

                <cfset name = reFindNoCase(namereg, functionblock, 1, true)>
                <cfset hint = reFindNoCase(hintreg, functionblock, 1, true)>
                <cfset rettype = reFindNoCase(rettypereg, functionblock, 1, true)>

                <cfset tmp = {}>

                <cfif ArrayLen(name.len) GT 1 AND ArrayLen(name.pos) GT 1>
                    <cfset tmp['name'] = mid(functionblock, name.pos[2], name.len[2])>
                </cfif>
                <cfif ArrayLen(hint.len) GT 1 AND ArrayLen(hint.pos) GT 1>
                    <cfset tmp['hint'] = mid(functionblock, hint.pos[2], hint.len[2])>
                </cfif>
                <cfif ArrayLen(rettype.len) GT 1 AND ArrayLen(rettype.pos) GT 1>
                    <cfset tmp['rettype'] = mid(functionblock, rettype.pos[2], rettype.len[2])>
                </cfif>

                <cfset find = search.len[2] + search.pos[2]>

                <cfset endfunction = reFindNoCase(endfuncreg, fileRead, find, true)>

                <cfif ArrayLen(endfunction.pos) EQ 1 AND val(endfunction.pos[1])>

                    <cfset funcbody = mid(fileRead, search.pos[2], endfunction.pos[1] - search.pos[2])>

                    <cfset argsfind = 1>
                    <cfset tmp['args'] = []>

                    <cfloop condition="argsfind GT 0">

                        <cfset argsearch = reFindNoCase(argreg, funcbody, argsfind, true)>

                        <cfif ArrayLen(argsearch.len) GT 1 AND ArrayLen(argsearch.pos) GT 1>

                            <cfset argblock = mid(funcbody, argsearch.pos[2], argsearch.len[2])>

                            <cfset argname = reFindNoCase(namereg, argblock, 1, true)>
                            <cfset arghint = reFindNoCase(hintreg, argblock, 1, true)>
                            <cfset argtype = reFindNoCase(typereg, argblock, 1, true)>
                            <cfset argreq = reFindNoCase(reqreg, argblock, 1, true)>
                            <cfset argdef = reFindNoCase(defreg, argblock, 1, true)>

                            <cfset tmp2 = {}>

                            <cfif ArrayLen(argname.len) GT 1 AND ArrayLen(argname.pos) GT 1>
                                <cfset tmp2['name'] = mid(argblock, argname.pos[2], argname.len[2])>
                            </cfif>
                            <cfif ArrayLen(arghint.len) GT 1 AND ArrayLen(arghint.pos) GT 1>
                                <cfset tmp2['hint'] = mid(argblock, arghint.pos[2], arghint.len[2])>
                            </cfif>
                            <cfif ArrayLen(argtype.len) GT 1 AND ArrayLen(argtype.pos) GT 1>
                                <cfset tmp2['type'] = mid(argblock, argtype.pos[2], argtype.len[2])>
                            </cfif>
                            <cfif ArrayLen(argreq.len) GT 1 AND ArrayLen(argreq.pos) GT 1>
                                <cfset tmp2['required'] = mid(argblock, argreq.pos[2], argreq.len[2])>
                            </cfif>
                            <cfif ArrayLen(argdef.len) GT 1 AND ArrayLen(argdef.pos) GT 1>
                                <cfset tmp2['default'] = mid(argblock, argdef.pos[2], argdef.len[2])>
                            </cfif>

                            <cfset argsfind = argsearch.len[2] + argsearch.pos[2]>

                            <cfif !StructIsEmpty(tmp2)>
                                <cfset ArrayAppend(tmp['args'], StructCopy(tmp2))>
                            </cfif>
                        <cfelse>
                            <cfset argsfind = 0>
                        </cfif>
                    </cfloop>

                </cfif>

                <cfif !StructIsEmpty(tmp)>
                    <cfset ArrayAppend(functions, StructCopy(tmp))>
                </cfif>

            <cfelse>
                <cfset find = 0>
            </cfif>
        </cfloop>

    </cfif>

</cfif>
<!---------------------------- 
END Form Submitted Section     
------------------------------>

<!---------------------------- 
        Query Section          
------------------------------>
<cfdirectory
    action="list"
    directory="#componentDirectory#"
    filter="*.cfc"
    sort="name"
    name="components" />
<!---------------------------- 
        END Query Section      
------------------------------>
                    
<!---------------------------- 
        Display Section        
------------------------------>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>View Component Functions</title>
<script src="//code.jquery.com/jquery-2.1.0.min.js"></script>

<style>
	body {
		font-family: Calibri, Candara, Segoe, "Segoe UI", Optima, Arial, sans-serif;
		background-color: #E6E6E6;
		padding: 1em;
	}
    .functionlist,
    .functions {
        float: left;
        margin-right: 1em;
    }
    .functionlist {
        box-shadow: 0 3px 3px 0 #ccc;
        background-color: white;
        padding: .5em;
    }
    .functionlist li {
        font-size: .9em;
        padding: .1em;
    }
    .functionlist li a {
        color: #333;
        text-decoration: none;
    }
    .functionlist li a:hover {
        text-decoration: underline;
        color: blue;
    }
    .function {
        margin: .5em;
        border: 1px solid #ccc;
        box-shadow: 0 3px 3px 0 #ccc;
        background-color: white;
    }
    .name {
        padding: .5em .5em 0 .5em;
        font-size: 1.2em;
        font-weight: bold;
    }
    .hint,
    .arghint {
        clear: both;
        font-style: italic;
        padding: .5em .5em .5em 1em;
    }
    .rettype,
    .argtype {
        display: inline-block;
        float: right;
        font-size: .8em;
        font-weight: normal;
        padding: .5em .5em .5em 1em;
        text-decoration: underline;
    }
    .arguments {
        margin: 1em;
        box-shadow: 0 0 1px 1px rgba(0, 0, 0, .05);
    }
    .argument {
        border: 1px dotted rgba(0, 0, 0, .1);
    }
    .argname {
        padding: .5em .5em 0 .5em;
        font-weight: bold;
        display: inline-block;
    }
    .argrequired {
        padding: .5em .5em .5em 1em;
    }

</style>
</head>
<body>

	<h2>Choose Component</h2>
	<br/>
	<form action="" method="get">
	    <select name="component">
	        <option value=""></option>
	        <cfoutput query="components">
	            <option value="#components.name#" <cfif !CompareNoCase(component, components.name)>selected="selected"</cfif>>#components.name#</option>
	        </cfoutput>
	    </select>
	    <button type="submit">Get Functions</button>
	</form>
	<br/><br/>
	<cfif ArrayLen(functions)>
	    <cfoutput>
	        <div class="functionlist">
	            <ul>
	                <li><a href="##" data-showall>Show All</a></li>
	            </ul>
	            <ol>
	                <cfloop array="#functions#" index="func">
	                    <li><a href="###func.name#" data-show="#func.name#">#func.name#</a></li>
	                </cfloop>
	            </ol>
	        </div>
	        <div class="functions">
	            <cfloop array="#functions#" index="func">
	                <div class="function" data-element="#func.name#">
	                    <div class="name">
	                        #func.name#
	                        <cfif StructKeyExists(func, "rettype")>
	                            <div class="rettype">
	                                Return Type: #func.rettype#
	                            </div>
	                        </cfif>
	                    </div>
	                    <cfif StructKeyExists(func, "hint")>
	                        <div class="hint">
	                            #func.hint#
	                        </div>
	                    </cfif>
	                    <cfif StructKeyExists(func, "args") AND IsArray(func.args) AND ArrayLen(func.args)>
	                        <div class="arguments">
	                            <cfloop array="#func.args#" index="arg">
	                                <div class="argument">
	                                    <cfif StructKeyExists(arg, "name")>
	                                        <div class="argname">
	                                            #arg.name#
	                                        </div>
	                                    </cfif>
	                                    <cfif StructKeyExists(arg, "type")>
	                                        <div class="argtype">
	                                            #arg.type#
	                                        </div>
	                                    </cfif>
	                                    <cfif StructKeyExists(arg, "hint")>
	                                        <div class="arghint">
	                                            #arg.hint#
	                                        </div>
	                                    </cfif>
	                                    <div class="argrequired">
	                                        <cfif StructKeyExists(arg, "required")>
	                                            Required: #arg.required#
	                                        </cfif>
	                                        <cfif StructKeyExists(arg, "default")>
	                                            <cfif StructKeyExists(arg, "required")>
	                                                <br/>
	                                            </cfif>
	                                            Default: #arg.default#
	                                        </cfif>
	                                    </div>
	                                </div>
	                            </cfloop>
	                        </div>
	                    </cfif>
	                </div>
	            </cfloop>
	        </div>
	    </cfoutput>
	</cfif>

	<script>
	    (function() {
	        $('[data-show]').click(function(e) {
	            showelement($(this).attr('data-show'));
	        });

	        $('[data-showall]').click(function(e) {
	            $('[data-element]:hidden').show();
	        });

	        showelement(window.location.href.split('#')[1]);

	        function showelement(name) {

	        	var el = null;

	        	if (typeof(name) !== "undefined") {
		        	el = $('[data-element="' + name + '"]');
		       	} else {
		       		el = $('[data-element]');
		       	}

				$('[data-element]:visible').hide();
		        el.show();
	        }
	    })();
	</script>
</body>
</html>
