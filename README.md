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
|            @           | Path     | **REQUIRED** | Exactly one  | Path of the backup destination folder |                                       |
|            +           | Path     | OPTIONAL     | Zero or more | Path to be included into the backup   | Path is relative to the source folder |
|            -           | Path     | OPTIONAL     | Zero or more | Path to be excluded from the backup   | Path is relative to the source folder |