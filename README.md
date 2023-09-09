## RSYNC backup script
This is a simple script to help to define multiple backup task to be executed with RSYNC.

Tasks are defined in a `tasks.txt` file, with a well defined [syntax](#task-syntax).

Once the script is executed, it simply reads tasks defined in the `tasks.txt` file and execute them.


## Tasks syntax
Backup tasks are defined in a `tasks.txt` file. To summarize, a backup task is a block of lines with the following syntax.

```
-> source/path/
@ dest/path/
+included/path/
+included/file.txt
-exluded/path/
-excluded/file.txt
<-
```

In details, a task block:

1. **MUST** start with a start line

    ```
    -> /source/path/
    ```

2. **MUST** end with a end line

    ```
    <-
    ```

3. Between the start line and the end line there are the [configuration lines](#configuration-lines)

4. All other lines will be ignored

### Configuration lines

| **Starting Character** | **Type** | **Required** | **Quantity** |            **Description**            |                **Note**               |
|:----------------------:|:--------:|:------------:|:------------:|:-------------------------------------:|:-------------------------------------:|
|            @           | Path     | **REQUIRED** | Exactly one  | Path of the backup destination folder | See Note 1                        |
|            +           | Path   | OPTIONAL     | Zero or more | Path to be included into the backup   | Path is relative to the source folder |
|            -           | Path     | OPTIONAL     | Zero or more | Path to be excluded from the backup   | Path is relative to the source folder |

Notes:

1. Rsync just copy the source folder content into the destination folder. So make sure that your destination is an empty folder that match with the source.
2. Include/Exclude Paths could be also Patterns. See the rsync [man](https://man.cx/rsync(1)) page, section `PATTERN MATCHING RULES`

### Tip: include only some file/folders in your backup
If you want to backup only some files or folder of the source directory, use this pattern for your task

```
-> /path/to/backup
@ /destination/directory/
+ included_file.ext
+ included_folder/***
- *
<-
```

In this way we exclude all the file and folders, except for the ones we have included.

> **Note about the triple asterisk notation (`included_folder/***`)**
>
> From the rsync man page: *trailing `dir_name/***` will match both the directory (as if `dir_name/` had been specified) and everything in the directory (as if `dir_name/**` had been specified)*.
>
> So `included_folder/***` means in one line: *include both the `included_folder` folder and all its content*
>
> See below for why wee need this. 


Note that for the [way rsync works](https://stackoverflow.com/a/15701772), if the folder you want include is deeper in the source directory structure, **you must define an include line for each ancestor of the required folder**.

For example if your source directory is `/home/homeassistant/.homeassistant/` and the folder you want to backup is `/home/homeassistant/.homeassistant/custom_components/sonoff/`, your task will be

```
-> /home/homeassistant/.homeassistant/
@ /dest/path/
+custom_components/
+custom_components/sonoff/***
- *
<-
```

> Note the use of the triple asterisk pattern!
>
> As noted above, with the triple asterisk pattern we were able to save an include line in the task definition.
>
> In fact, without this notation, the task would be
> ```
> -> /home/homeassistant/.homeassistant/
> @ /dest/path/
> +custom_components/
> +custom_components/sonoff/
> +custom_components/sonoff/**
> - *
> <-
> ```