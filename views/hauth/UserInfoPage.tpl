<div class="row subsystem-header">
    <div class="pull-left">
        <span style="font-size: 14px;">用户管理</span>
    </div>
</div>
<div class="row subsystem-toolbar">
    <div style="height: 44px; line-height: 44px;display: inline;">
{{if checkResIDAuth "2" "0105010700"}}
        <!--用户搜索区域，只有被授予搜搜权限的用户，才能看到此区域-->
        <span style="font-size: 10px;font-weight: 600;" class="pull-left">&nbsp;&nbsp;机构:</span>
        <select id="h-user-org-list" class="form-control pull-left"
                style="width: 180px;height: 24px; line-height: 24px; margin-top: 10px; padding: 0px;">
        </select>
        <span style="font-size: 10px;font-weight: 600;" class="pull-left">&nbsp;&nbsp;状态:</span>
        <select id="h-user-status-list" class="form-control pull-left"
                style="width: 180px;height: 24px; line-height: 24px; margin-top: 10px;padding: 0px;">
            <option value="0">正常</option>
            <option value="1">失效</option>
        </select>
        <button onclick="UserObj.search()" class="btn btn-default btn-xs pull-left" style="margin-left: 8px; margin-top: 11px;">查询
        </button>
        <!--end 用户搜索区域-->
{{end}}
    </div>
    <div class="pull-right">
        &nbsp;
        {{if checkResIDAuth "2" "0105010200"}}
        <button onclick="UserObj.add()" class="btn btn-info btn-sm">
            <i class="icon-plus"> 新增</i>
        </button>
        {{end}}
        {{if checkResIDAuth "2" "0105010300"}}
        <button onclick="UserObj.edit()" class="btn btn-info btn-sm" title="下载操作记录">
            <span class="icon-edit"> 编辑</span>
        </button>
        {{end}}
        {{if checkResIDAuth "2" "0105010400"}}
        <button onclick="UserObj.delete()" class="btn btn-danger btn-sm" title="下载操作记录">
            <span class="icon-trash"> 删除</span>
        </button>
        {{end}}
    </div>
</div>
<div id="h-user-show-box" class="subsystem-content">
    <table id="h-user-info-table-details"
           data-toggle="table"
           data-unique-id="user_id"
           data-side-pagination="client"
           data-click-to-select="true"
           data-pagination="true"
           data-striped="true"
           data-show-refresh="false"
           data-page-size="30"
           data-page-list="[30, 50, 100, 200]"
           data-search="false">
        <thead>
        <tr>
            <th data-field="state" data-checkbox="true"></th>
            <th data-field="user_id" data-sortable="true">账户</th>
            <th data-field="user_name">用户名称</th>
            <th data-align="center" data-field="status_desc">状态</th>
            <th data-field="org_unit_desc" data-sortable="true">机构</th>
            <th data-align="center" data-field="user_phone">手机号</th>
            <th data-field="user_email">邮箱</th>
            <!--<th data-align="center" data-field="create_user">创建人</th>-->
            <!--<th data-align="center" data-field="create_date" data-sortable="true">创建时间</th>-->
            <th data-align="center" data-field="modify_user">修改人</th>
            <th data-align="center" data-field="modify_date" data-sortable="true">修改时间</th>
            <th data-align="center" data-formatter="UserObj.formatter">操作</th>
        </tr>
        </thead>
    </table>
</div>
<script>
    NProgress.start();
    $(document).ready(function(e){
        /*
        * 初始化table
        * 获取默认域下边所有用户信息
        * */
        $("#h-user-info-table-details").bootstrapTable({
            url:"/v1/auth/user/get",
        });

        /*
         * 初始化默认域下的机构树信息
         * */
        $.getJSON("/v1/auth/org/get",function(data){
            var arr = new Array();
            $(data).each(function(index,element){
                var ijs = {};
                ijs.id=element.org_id;
                ijs.text=element.org_desc;
                ijs.upId=element.up_org_id;
                arr.push(ijs)
            });

            $("#h-user-org-list").Hselect({
                data:arr,
                height:"24px",
                width:"280px",
            });
        });

        // 机构状态选择框
        $("#h-user-status-list").Hselect({
            height:"24px",
            width:"180px",
            value:0,
        });
        NProgress.done();
    });

    var UserObj = {
        add:function(){
            var getDomainInfo = function () {
                $.getJSON("/v1/auth/org/get",function(data){
                    var arr = new Array()
                    $(data).each(function(index,element){
                        var ijs = {}
                        ijs.id=element.org_id;
                        ijs.text=element.org_desc;
                        ijs.upId=element.up_org_id;
                        arr.push(ijs)
                    });
                    $("#h-add-org-unit-list").Hselect({
                        data:arr,
                        height:"30px",
                    })
                });

                $("#h-user-add-info")
                    .find("select[name='status_cd']")
                    .Hselect({
                        height:"30px"
                    });

            };

            $.Hmodal({
                header:"新增用户",
                body:$("#user_input_form").html(),
                width:"420px",
                preprocess:getDomainInfo,
                callback:function(hmode){
                    $.HAjaxRequest({
                        url:"/v1/auth/user/post",
                        type:"post",
                        data:$("#h-user-add-info").serialize(),
                        dataType:"json",
                        success:function(){
                            $(hmode).remove()
                            $.Notify({
                                title:"操作成功",
                                message:"新增用户成功",
                                type:"success",
                            });
                            $("#h-user-info-table-details").bootstrapTable('refresh');
                        },
                    })
                }
            })
        },
        edit:function () {
            var rows = $("#h-user-info-table-details").bootstrapTable('getSelections');
            if (rows.length == 0){
                $.Notify({
                    message:"请在下列表中选择需要编辑的用户",
                    type:"info",
                });
                return
            } else if (rows.length == 1){
                $.Hmodal({
                    header:"修改用户信息",
                    body:$("#modify-user-info").html(),
                    width:"420px",
                    preprocess:function () {
                        $.getJSON("/v1/auth/org/get",function(data){
                            var arr = new Array()
                            $(data).each(function(index,element){
                                var ijs = {};
                                ijs.id=element.org_id;
                                ijs.text=element.org_desc;
                                ijs.upId=element.up_org_id;
                                arr.push(ijs);
                            });
                            $("#h-modify-org-id").Hselect({
                                data:arr,
                                height:"30px",
                                value:rows[0].org_unit_id
                            });
                        });

                        var dom = document.getElementById("h-user-modify-info");
                        dom.userId.value = rows[0].user_id;
                        dom.userId.setAttribute("readonly","readonly");
                        dom.userDesc.value = rows[0].user_name;
                        dom.userPhone.value  = rows[0].user_phone;
                        dom.userEmail.value  = rows[0].user_email;
                    },
                    callback:function (hmode) {
                        $.HAjaxRequest({
                            url:"/v1/auth/user/put",
                            type:"put",
                            data:$("#h-user-modify-info").serialize(),
                            success:function () {
                                $(hmode).remove();
                                $.Notify({
                                    message:"修改用户信息成功",
                                    type:"success",
                                });
                                $("#h-user-info-table-details").bootstrapTable('refresh');
                            }
                        })
                    }
                })
            } else {
                $.Notify({
                    message:"您选择了多个用户，不知道想要编辑哪一个用户信息",
                    type:"info",
                });
                return
            }
        },
        modifyPasswd:function (user_id) {
            $.Hmodal({
                header:"重置用户密码信息",
                body:$("#h-modify-password").html(),
                width:"420px",
                preprocess:function () {
                    $("#h-modify-user-password").val(user_id)
                },
                callback:function (hmode) {
                    $.HAjaxRequest({
                        url:"/v1/auth/user/modify/passwd",
                        type:"put",
                        data:$("#plat-change-userpasswd").serialize(),
                        success:function () {
                            $(hmode).remove();
                            $.Notify({
                                message:"重置用户密码成功",
                                type:"success",
                            });
                        },
                    })
                },
            })
        },
        modifyStatus:function (user_id,status_id,user_name) {
            $.Hmodal({
                header:"修改用户状态",
                body:$("#modify-user-status").html(),
                width:"420px",
                preprocess:function () {
                    $("#h-modify-user-status-user-id").val(user_id);
                    $("#h-modify-user-status-user-name").val(user_name);

                    $("#h-modify-user-status-user-status").Hselect({
                        height:"30px",
                        value:status_id
                    });
                },
                callback:function (hmode) {
                    $.HAjaxRequest({
                        url:"/v1/auth/user/modify/status",
                        type:"put",
                        data:$("#h-user-modify-info-status").serialize(),
                        success:function () {
                            $(hmode).remove();
                            $.Notify({
                                message:"重置用户状态成功",
                                type:"success"
                            });
                            $("#h-user-info-table-details").bootstrapTable("refresh");
                        },
                    })
                },
            })
        },
        delete:function(){
            var $table = $("#h-user-info-table-details")
            var obj =$table.bootstrapTable('getSelections')

            if (obj.length === 0){
                $.Notify({
                    message:"请在下列表中选择需要编辑的用户",
                    type:"info"
                });
                return;
            } else {
                $.Hconfirm({
                    body:"点击确定删除选中的用户",
                    callback:function () {
                        $.HAjaxRequest({
                            url:"/v1/auth/user/delete",
                            type:"post",
                            data:{JSON:JSON.stringify(obj)},
                            dataType:"json",
                            success:function(){
                                $.Notify({
                                    message:"删除用户信息成功",
                                    type:"success"
                                });
                                $(obj).each(function (index, element) {
                                    $table.bootstrapTable("removeByUniqueId",element.user_id);
                                })
                            }
                        })
                    }
                })
            }
        },
        search:function(){
            var org_id = $("#h-user-org-list").val();
            var status_id = $("#h-user-status-list").val();
            var did = $("#h-user-domain-list").val();
            $.HAjaxRequest({
                url:"/v1/auth/user/search",
                type:"get",
                data:{org_id:org_id,status_id:status_id,domain_id:did},
                success:function (data) {
                    $("#h-user-info-table-details").bootstrapTable('load',data)
                },
            })
        },
        formatter:function(value,rows,index){
            var html = "-";
            {{if checkResIDAuth "2" "0105010500"}}
                html ='<span class="h-td-btn btn-primary btn-xs" onclick="UserObj.modifyPasswd(\''+rows.user_id+'\')">改密</span>';
            {{end}}
            {{if checkResIDAuth "2" "0105010600"}}
                html +='&nbsp;&nbsp;<span class="h-td-btn btn-success btn-xs" onclick="UserObj.modifyStatus(\''+rows.user_id+'\',\''+ rows.status_cd+'\',\''+ rows.user_name+'\')">解锁</span>';
            {{end}}
            return html;
        },
    }
</script>

<!--新增用户信息表格框-->
<script type="text/html" id="user_input_form">
    <form class="row" id="h-user-add-info">
        <div class="col-sm-12">
            <label class="h-label" style="width:100%;">账　号：</label>
            <input placeholder="3至30位字母，数字组成" name="user_id" type="text" class="form-control" style="width: 100%;height: 30px;line-height: 30px;">
        </div>
        <div class="col-sm-12 col-md-12 col-lg-12" style="margin-top: 8px;">
            <label class="h-label" style="width: 100%;">名　称：</label>
            <input placeholder="2至30位汉字，字母，数字组成" type="text" class="form-control" name="user_name" style="width: 100%;height: 30px;line-height: 30px;">
        </div>
        <div class="col-sm-12 col-md-12 col-lg-12" style="margin-top: 8px;">
            <label class="h-label" style="width: 100%;">机　构：</label>
            <select  id="h-add-org-unit-list"  name="org_unit_id" style="width: 100%;height: 30px;line-height: 30px;">
            </select>
        </div>
        <div class="col-sm-12 col-md-12 col-lg-12" style="margin-top: 8px;">
            <label class="h-label" style="width: 100%;">状　态：</label>
            <select name="status_cd" class="form-control" style="width: 100%;height: 30px;line-height: 30px;">
                <option value="0" selected="selected">正常</option>
                <option value="1">失效</option>
            </select>
        </div>
        <div class="col-sm-12 col-md-12 col-lg-12" style="margin-top: 8px;">
            <label class="h-label" style="width: 100%;">密　码：</label>
            <input placeholder="用户登录系统用到的密码" type="password" class="form-control" name="user_passwd" style="width: 100%;height: 30px;line-height: 30px;">
        </div>
        <div class="col-sm-12 col-md-12 col-lg-12" style="margin-top: 8px;">
            <label class="h-label" style="width: 100%;">确认密码：</label>
            <input placeholder="确认登录密码" type="password" class="form-control" name="user_passwd_confirm" style="width: 100%;height: 30px;line-height: 30px;">
        </div>
        <div class="col-sm-12 col-md-12 col-lg-12" style="margin-top: 8px;">
            <label class="h-label" style="width: 100%;">邮　箱：</label>
            <input placeholder="yourid@domain.com" name="user_email" type="text" class="form-control" style="width: 100%;height: 30px;line-height: 30px;">
        </div>
        <div class="col-sm-12 col-md-12 col-lg-12" style="margin-top: 8px;">
            <label class="h-label" style="width: 100%;">手机号：</label>
            <input placeholder="11位手机号码" name="user_phone" type="text" class="form-control" style="width: 100%;height: 30px;line-height: 30px;">
        </div>
    </form>
</script>

<!--修改用户信息框-->
<script type="text/html" id="modify-user-info">
    <form class="row" id="h-user-modify-info">
        <div class="col-sm-12">
            <label class="h-label" style="width:100%;">账　号：</label>
            <input placeholder="user id" name="userId" type="text" class="form-control" style="width: 100%;height: 30px;line-height: 30px; background-color: #f5f5f5;">
        </div>
        <div class="col-sm-12" style="margin-top: 12px;">
            <label class="h-label" style="width: 100%;">名　称：</label>
            <input placeholder="user name" type="text" class="form-control" name="userDesc" style="width: 100%;height: 30px;line-height: 30px;">
        </div>
        <div class="col-sm-12" style="margin-top: 12px;">
            <label class="h-label" style="width: 100%;">机　构：</label>
            <select id="h-modify-org-id" name="orgId" style="width: 100%;height: 30px;line-height: 30px;padding: 0px;">
            </select>
        </div>
        <div class="col-sm-12" style="margin-top: 12px;">
            <label class="h-label" style="width: 100%;">邮　箱：</label>
            <input placeholder="user email" name="userEmail" type="text" class="form-control" style="width: 100%;height: 30px;line-height: 30px;">
        </div>
        <div class="col-sm-12" style="margin-top: 12px;">
            <label class="h-label" style="width: 100%;">手机号：</label>
            <input placeholder="user phone number" name="userPhone" type="text" class="form-control" style="width: 100%;height: 30px;line-height: 30px;">
        </div>
    </form>
</script>

<script type="text/html" id="modify-user-status">
    <form class="row" id="h-user-modify-info-status">
        <div class="col-sm-12">
            <label class="h-label" style="width: 100%;">用户账号：</label>
            <input id="h-modify-user-status-user-id" readonly="readonly" title="不可编辑" name="userId" type="text" class="form-control" style="height: 30px; line-height: 30px;">
        </div>
        <div class="col-sm-12" style="margin-top: 12px;">
            <label class="h-label" style="width: 100%;">用户名称：</label>
            <input id="h-modify-user-status-user-name" readonly="readonly"  title="不可编辑" type="text" class="form-control" name="userDesc" style="height: 30px; line-height: 30px;">
        </div>
        <div class="col-sm-12" style="margin-top: 12px;">
            <label class="h-label" style="width: 100%;">用户状态：</label>
            <select id="h-modify-user-status-user-status" name="userStatus" class="form-control" style="width:100%;height: 30px; line-height: 30px;padding: 0px;">
                <option value="0">正常</option>
                <option value="1">失效</option>
            </select>
        </div>
    </form>
</script>

<script id="h-modify-password" type="text/html">
    <form class="row" id="plat-change-userpasswd">
        <div class="col-sm-12">
            <label class="h-label" style="width: 100%;">用户账号：</label>
            <input id="h-modify-user-password" readonly="readonly" class="form-control" style="width: 100%;height: 30px; line-height: 30px;" type="text" name="userid"/>
        </div>
        <div class="col-sm-12" style="margin-top: 12px;">
            <label class="h-label" style="width: 100%;">新密码：</label>
            <input placeholder="密码长度必须大于6位，小于30位" class="form-control" style="width:100%;height: 30px; line-height: 30px;" type="password" name="newpasswd"/>
        </div>
        <div class="col-sm-12" style="margin-top: 12px;">
            <label class="h-label" style="width: 100%;">确认密码：</label>
            <input placeholder="请确认新密码信息" class="form-control" style="height: 30px; line-height: 30px; width: 100%;" type="password" name="surepasswd"/>
        </div>
    </form>
</script>