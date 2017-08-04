---
title: mybatis实现自动分页
date: 2017-07-27 17:41:22
tags:
 - mybatis
---
这两天在学习mybatis，然后尝试的实现一个mybatis自动分页的功能，在网上google了很多，但是都是东拼西凑的比较多，没有很好正常的运行的。所以我这里记录一下。
<!--more-->
## 使用到的技术介绍
如果是要实现光mybatis实现的话，那就要jdbc、数据库是必须的，我们用到的是mybatis插件（plugin）的这个功能。然后这里贴一点官方的描述
> Executor (update, query, flushStatements, commit, rollback,   getTransaction, close, isClosed)
 ParameterHandler (getParameterObject, setParameters)
 ResultSetHandler (handleResultSets, handleOutputParameters)
 StatementHandler (prepare, parameterize, batch, update, query)
 摘自 [myabtis官方资料](http://www.mybatis.org/mybatis-3/zh/configuration.html#mappers)

说这个的目的是为了，记录一点是 使用Executor这个来进行数据库操作（因为他给我们的是一个MappedStatement参数）我们无法获取到处理数据库操作的handler，所以我们能用的就只有`StatementHandler`.通过这个去进行数据库总数的查询。完全实现数据库的自动分页的功能。

## 实现自动分页的步骤

### 编写拦截器
拦截器实现`Interceptor`的接口然后注释定义类型（这些类型的参数 和类型 方法都可以在网上或者myabtis源码中查找到）

下面是我写的代码，然后这个代码不是很好没有进行多方面的解耦和其他的操作，只是一个最简单的样例，可以大致看一下思想，有时间再改一版：
```java
import org.apache.ibatis.executor.parameter.ParameterHandler;
import org.apache.ibatis.executor.statement.RoutingStatementHandler;
import org.apache.ibatis.executor.statement.StatementHandler;
import org.apache.ibatis.mapping.BoundSql;
import org.apache.ibatis.mapping.MappedStatement;
import org.apache.ibatis.plugin.*;
import org.apache.ibatis.reflection.MetaObject;
import org.apache.ibatis.reflection.SystemMetaObject;
import java.lang.annotation.Annotation;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;
import java.util.Properties;

@Intercepts( {
        @Signature(method = "prepare",
                type = StatementHandler.class,
                args = { Connection.class ,Integer.class}) })
public class preparePageInterceptor implements Interceptor {
    //每页显示的条目数
    private int pageSize = 10;
    //当前现实的页数
    private int currPage = 1;
    private String dbType;
    public Object intercept(Invocation invocation) throws Throwable {
        //获取StatementHandler，默认是RoutingStatementHandler
        RoutingStatementHandler handler = (RoutingStatementHandler) invocation.getTarget();
        //获取statementHandler包装类
        MetaObject MetaObjectHandler = SystemMetaObject.forObject(handler);
        //分离代理对象链
        while (MetaObjectHandler.hasGetter("h")) {
            Object obj = MetaObjectHandler.getValue("h");
            MetaObjectHandler = SystemMetaObject.forObject(obj);
        }

        while (MetaObjectHandler.hasGetter("target")) {
            Object obj = MetaObjectHandler.getValue("target");
            MetaObjectHandler = SystemMetaObject.forObject(obj);
        }
        //获取连接对象
        //Connection connection = (Connection) invocation.getArgs()[0];
        //object.getValue("delegate");  获取StatementHandler的实现类
        //获取查询接口映射的相关信息
        MappedStatement mappedStatement = (MappedStatement) MetaObjectHandler.getValue("delegate.mappedStatement");
        String mapId = mappedStatement.getId();
        //statementHandler.getBoundSql().getParameterObject();
        //拦截以.ByPage结尾的请求，分页功能的统一实现
        if (mapId.matches(".+ByPage$")) {
            BoundSql boundSql = handler.getBoundSql();
            //设置总的页数
            setTotalSize(handler.getParameterHandler(), boundSql, (Connection) invocation.getArgs()[0]);

            //-----------
            System.out.println("进来了");
            //获取进行数据库操作时管理参数的handler
            ParameterHandler parameterHandler = (ParameterHandler) MetaObjectHandler.getValue("delegate.parameterHandler");
            //获取请求时的参数
            Map<String, Object> paraObject = (Map<String, Object>) parameterHandler.getParameterObject();
            //也可以这样获取
            //paraObject = (Map<String, Object>) statementHandler.getBoundSql().getParameterObject();

            //参数名称和在service中设置到map中的名称一致

//            System.out.println(paraObject.get("currPage"));
            if (paraObject != null && paraObject.size()!=0) {
//
                currPage = (Integer) (paraObject.get("currPage")==null?1:paraObject.get("currPage"));
                pageSize =  (Integer) ( paraObject.get("pageSize")==null?10: paraObject.get("pageSize"));
            }
            String sql = (String) MetaObjectHandler.getValue("delegate.boundSql.sql");
            //也可以通过statementHandler直接获取
            //sql = statementHandler.getBoundSql().getSql();
            //构建分页功能的sql语句
            String limitSql;
            sql = sql.trim();
            limitSql = sql + " limit " + (currPage - 1) * pageSize + "," + pageSize;

            //将构建完成的分页sql语句赋值个体'delegate.boundSql.sql'，偷天换日
            MetaObjectHandler.setValue("delegate.boundSql.sql", limitSql);
        }
        return invocation.proceed();
    }

    //获取代理对象
    public Object plugin(Object o) {
        return Plugin.wrap(o, this);
    }

    //设置代理对象的参数
    public void setProperties(Properties properties) {
//如果项目中分页的pageSize是统一的，也可以在这里统一配置和获取，这样就不用每次请求都传递pageSize参数了。参数是在配置拦截器时配置的。
        String limit1 = properties.getProperty("limit", "10");
        this.pageSize = Integer.valueOf(limit1);
        this.dbType = properties.getProperty("dbType", "mysql");
    }
    /**
     * 查询总记录数
     * @param parameterHandler
     * @param boundSql
     * @param conn
     */
    private void setTotalSize(ParameterHandler parameterHandler, BoundSql boundSql, Connection conn) {
        String countSql = "select count(1) from (" + boundSql.getSql() + ") t";

        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            pstmt = conn.prepareStatement(countSql);
            parameterHandler.setParameters(pstmt);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                // 设置总记录数
                System.out.println(rs.getInt(1));
//                page.setTotalSize(rs.getInt(1));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null)
                    rs.close();
                if (pstmt != null)
                    pstmt.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
```
### 启用mybatis的configuration进行插件绑定
下面是绑定的代码,这个是我的拦截器代码类的项目内地址，然后还可以用property参数进行基本参数设置，如果是spring集成的话还可以在spring的sqlSessionFactory进行配置。具体的就百度吧。
```xml
 <plugins>
        <plugin interceptor="org.interceptor.preparePageInterceptor">
        </plugin>
</plugins>
```

### 使用说明
这个事例写的有点不太好，他是通过mapper id进行数据拦截绑定的就是说，要id是`ByPage`结尾的才会进行拦截，然后执行一个查找总表的操作。还有就是应该思考一下如何进行有条件判断下的总记录数的查询。

还需要注意的是，数据库操作有些有可能要根据不同的数据库修改limit 和查找总记录的语句

## 总结
基本就是这些了，时间感觉每天都不太够用。一晃一天就过去了。唉，等有时间了再来详细的了解吧