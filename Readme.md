# Mathpix

Install the function by:

```Mathematica
Import@"https://github.com/Moe-Net/Mathpix/blob/master/Mathpix.m"
```

Apply for your API Key from https://dashboard.mathpix.com/signup, with one thousand free credits per month

Then set your key and load the function:

```Mathematica
PersistentValue["Mathpix", "Local"]={"$KeyName","$KeyValue"};
```

## Usage

Mathpix receives a `Image`, or the `String` of path to the image, or `MathpixAPI` object

And have the following modes: `{N, D, E, "Raw"}`

## NormalMode

![Normal](https://i.loli.net/2018/12/01/5c0248400385c.png)

## DisplayMode

![Display](https://i.loli.net/2018/12/01/5c0248402b4b5.png)

## ExpressionMode

![Expression](https://i.loli.net/2018/12/01/5c02483fae878.png)

## RawMode

![Raw](https://i.loli.net/2018/12/01/5c024926664f1.png)