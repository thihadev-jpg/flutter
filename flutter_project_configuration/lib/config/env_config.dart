enum Flavor{
  dev,
  stage,
  prod
}

class EnvConfig {
  static Flavor appFlavor = Flavor.dev;

  static String get baseUrl{
    switch(appFlavor){
      case Flavor.dev :
        return 'development url';
      case Flavor.stage :
        return 'staging url';
      case Flavor.prod :
        return 'production url';
    }
  }
}