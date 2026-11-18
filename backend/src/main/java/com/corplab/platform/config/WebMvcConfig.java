package com.corplab.platform.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.io.File;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        // Automatically redirects http://localhost:8080/ to http://localhost:8080/login.html
        registry.addRedirectViewController("/", "/login.html");
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String projectDir = System.getProperty("user.dir");
        // Points to frontend folder in the project root
        String frontendPath = "file:" + projectDir + File.separator + "frontend" + File.separator;

        registry.addResourceHandler("/**")
                .addResourceLocations(
                        frontendPath,
                        "file:C:/Corparate training resource & lab infrastructure management system/frontend/",
                        "classpath:/static/",
                        "classpath:/public/"
                );
    }
}
